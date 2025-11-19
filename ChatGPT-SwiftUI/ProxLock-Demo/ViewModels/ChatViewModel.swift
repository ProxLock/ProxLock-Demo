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
        
        let messageToSend = inputText
        inputText = ""
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await service.sendMessage(messages: messages)
            let assistantMessage = ChatMessage(role: .assistant, content: response)
            messages.append(assistantMessage)
        } catch {
            errorMessage = error.localizedDescription
            // Remove the user message if there was an error
            if let index = messages.firstIndex(where: { $0.id == userMessage.id }) {
                messages.remove(at: index)
            }
        }
        
        isLoading = false
    }
    
    func clearChat() {
        messages.removeAll()
        errorMessage = nil
    }
}

