//
//  OpenAIService.swift
//  ProxLock-Demo
//
//  Created by Morris Richman on 11/13/25.
//

import Foundation
import ProxLock

class OpenAIService {
    private let session: PLSession
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(partialKey: String, associationID: String) {
        self.session = PLSession(
            partialKey: partialKey,
            associationID: associationID
        )
    }
    
    func sendMessage(messages: [ChatMessage]) async throws -> String {
        let request = try makeChatRequest(messages: messages, stream: false)
        let (data, response) = try await session.data(for: request)

        return try parseChatResponse(from: data, response: response)
    }

    func streamMessage(messages: [ChatMessage]) async throws -> AsyncThrowingStream<String, Error> {
        let request = try makeChatRequest(messages: messages, stream: true)
        let proxiedRequest = try await session.processURLRequest(request)

        let (bytes, response) = try await URLSession.shared.bytes(for: proxiedRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            var errorData = Data()
            for try await byte in bytes {
                errorData.append(byte)
            }
            throw parseAPIError(from: errorData) ?? OpenAIError.httpError(httpResponse.statusCode)
        }

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await line in bytes.lines {
                        guard let payload = line.openAIStreamPayload else {
                            continue
                        }

                        if payload == "[DONE]" {
                            continuation.finish()
                            return
                        }

                        if let chunk = try Self.contentChunk(from: payload) {
                            continuation.yield(chunk)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func makeChatRequest(messages: [ChatMessage], stream: Bool) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Use ProxLock's bearerToken which will be replaced server-side
        request.setValue("Bearer \(session.bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if stream {
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages.map { message in
                [
                    "role": message.role.rawValue,
                    "content": message.content
                ]
            },
            "stream": stream
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }

    private static func contentChunk(from payload: String) throws -> String? {
        guard let data = payload.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw OpenAIError.invalidResponse
        }

        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw OpenAIError.apiError(message)
        }

        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let delta = firstChoice["delta"] as? [String: Any] else {
            return nil
        }

        return delta["content"] as? String
    }

    private func parseAPIError(from data: Data) -> OpenAIError? {
        guard let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = errorData["error"] as? [String: Any],
              let message = error["message"] as? String else {
            return nil
        }

        return .apiError(message)
    }

    private func parseChatResponse(from data: Data, response: URLResponse) throws -> String {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let apiError = parseAPIError(from: data) {
                throw apiError
            }
            throw OpenAIError.httpError(httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.invalidResponse
        }
        
        return content
    }
}

private extension String {
    var openAIStreamPayload: String? {
        guard hasPrefix("data:") else {
            return nil
        }

        return dropFirst("data:".count).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .apiError(let message):
            return message
        }
    }
}
