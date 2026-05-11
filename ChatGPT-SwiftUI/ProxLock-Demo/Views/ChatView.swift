//
//  ChatView.swift
//  ProxLock-Demo
//
//  Created by Morris Richman on 11/13/25.
//

import SwiftUI
import UIKit

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.messages.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "bubble.left.and.bubble.right")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("Start a conversation")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    Text("Type a message below to begin chatting with ChatGPT")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 100)
                            }
                            
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .equatable()
                                    .id(message.id)
                            }
                            
                            if viewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: viewModel.messages.last?.content) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                        Button {
                            viewModel.errorMessage = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                }
                
                // Input Area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(24)
                        .lineLimit(1...5)
                        .disabled(viewModel.isLoading)
                        .onSubmit {
                            Task {
                                await viewModel.sendMessage()
                            }
                        }
                    
                    Button {
                        Task {
                            await viewModel.sendMessage()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.inputText.isEmpty || viewModel.isLoading ? .gray : .blue)
                    }
                    .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .navigationTitle("ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearChat()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .onAppear {
                if !viewModel.hasProxLockCredentials() {
                    showSettings = true
                }
            }
        }
    }
}

struct MessageBubbleView: View, Equatable {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                BubbleTextView(
                    text: message.content,
                    color: message.role == .user ? .white : .label
                )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user
                            ? Color.blue
                            : Color(.systemGray5)
                    )
                    .cornerRadius(20)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
    }
}

struct BubbleTextView: UIViewRepresentable {
    let text: String
    let color: UIColor
    private let fallbackWidth: CGFloat = 280

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        label.text = text
        label.textColor = color
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView label: UILabel, context: Context) -> CGSize? {
        let width = proposal.width ?? fallbackWidth
        return label.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )
    }
}

#Preview {
    ChatView()
}
