//
//  SettingsView.swift
//  ProxLock-Demo
//
//  Created by Morris Richman on 11/13/25.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var partialKey: String = ""
    @State private var associationID: String = ""
    @State private var showPartialKey: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Partial Key")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if showPartialKey {
                                TextField("Enter partial key", text: $partialKey)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Enter partial key", text: $partialKey)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                            }
                            
                            Button {
                                showPartialKey.toggle()
                            } label: {
                                Image(systemName: !showPartialKey ? "eye.slash" : "eye")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Association ID")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter association ID", text: $associationID)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("ProxLock Credentials")
                } footer: {
                    Text("Your ProxLock credentials are stored locally on your device and never shared. Get your credentials from the ProxLock web dashboard at https://docs.proxlock.dev")
                }
                
                Section {
                    Button {
                        viewModel.setProxLockCredentials(partialKey: partialKey, associationID: associationID)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(partialKey.isEmpty || associationID.isEmpty)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !partialKey.isEmpty && !associationID.isEmpty {
                            viewModel.setProxLockCredentials(partialKey: partialKey, associationID: associationID)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let savedPartialKey = UserDefaults.standard.string(forKey: "proxlock_partial_key") {
                    partialKey = savedPartialKey
                }
                if let savedAssociationID = UserDefaults.standard.string(forKey: "proxlock_association_id") {
                    associationID = savedAssociationID
                }
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: ChatViewModel())
}

