//
//  SettingsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            
            .background(Color(uiColor: .systemBackground))
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var isPremium = true
    var body: some View {
        NavigationStack {
            List {
                accountSection
                    .removeListRowFormatting()
                purchaseSection
                    .removeListRowFormatting()
                applicationSection
                    .removeListRowFormatting()
            }
            .navigationTitle("Settings")
        }
        .background(Color(uiColor: .systemBackground))
        
    }
    
    private var accountSection: some View {
        Section {
            Text("Sign out")
                .padding(.leading)
                .rowFormatting()
                .anyButton(.highlight) {
                    onSignOutPressed()
                }
               
            Text("Delete account")
                .padding(.leading)
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    
                }
        } header: {
            Text("Account")
        }
    }
    private var purchaseSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "Premium" : "Free")")
                    .padding(.leading)
                Spacer(minLength: 0)
                if isPremium {
                    Text("MANAGE")
                        .badgeButton()
                        .padding(.trailing)
                }
            }
                .rowFormatting()
                .anyButton(.highlight) {
                
                }
                .disabled(!isPremium)
        } header: {
            Text("Purchases")
        }
    }
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Version")
                    .padding(.leading)
                Spacer(minLength: 0)
                Text("1.0")
                    .padding(.trailing)
                    .foregroundStyle(.secondary)
            }
                .rowFormatting()
            
            HStack(spacing: 8) {
                Text("Build Number")
                    .padding(.leading)
                Spacer(minLength: 0)
                Text("3")
                    .padding(.trailing)
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            
            Text("Contact us")
                .padding(.leading)
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    
                }
                
        } header: {
            Text("Application")
        } footer: {
            Text("Created by Lacker Studios")
                .baselineOffset(6)
        }
    }
    private func onSignOutPressed() {
        // do some logic to sign user out of
        dismiss()
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
