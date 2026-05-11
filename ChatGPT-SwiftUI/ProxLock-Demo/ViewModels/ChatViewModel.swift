//
//  ChatViewModel.swift
//  ProxLock-Demo
//
//  Created by Morris Richman on 11/13/25.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    private var openAIService: OpenAIService?
    private let partialKeyStorageKey = "proxlock_partial_key"
    private let associationIDStorageKey = "proxlock_association_id"
    
    init() {
        loadProxLockCredentials()
    }
    
    func setProxLockCredentials(partialKey: String, associationID: String) {
        UserDefaults.standard.set(partialKey, forKey: partialKeyStorageKey)
        UserDefaults.standard.set(associationID, forKey: associationIDStorageKey)
        openAIService = OpenAIService(partialKey: partialKey, associationID: associationID)
    }
    
    func loadProxLockCredentials() {
        if let partialKey = UserDefaults.standard.string(forKey: partialKeyStorageKey),
           let associationID = UserDefaults.standard.string(forKey: associationIDStorageKey),
           !partialKey.isEmpty, !associationID.isEmpty {
            openAIService = OpenAIService(partialKey: partialKey, associationID: associationID)
        }
    }
    
    func hasProxLockCredentials() -> Bool {
        return openAIService != nil
    }
    
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard let service = openAIService else {
            errorMessage = "Please set your ProxLock credentials in Settings"
            return
        }
        
        let userMessage = ChatMessage(role: .user, content: inputText)
        messages.append(userMessage)
        let requestMessages = messages
        
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        var assistantMessageID: String?

        do {
            for try await chunk in try await service.streamMessage(messages: requestMessages) {
                if let assistantMessageID,
                   let index = messages.firstIndex(where: { $0.id == assistantMessageID }) {
                    messages[index].content += chunk
                } else {
                    let assistantMessage = ChatMessage(role: .assistant, content: chunk)
                    assistantMessageID = assistantMessage.id
                    messages.append(assistantMessage)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            // Remove the pending exchange if there was an error
            messages.removeAll { message in
                let isAssistantMessage = assistantMessageID.map { message.id == $0 } ?? false
                return message.id == userMessage.id || isAssistantMessage
            }
        }
        
        isLoading = false
    }
    
    func clearChat() {
        messages.removeAll()
        errorMessage = nil
    }
}
