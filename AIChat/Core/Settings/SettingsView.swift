//
//  SettingsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager

    @Environment(AppState.self) private var appState
    @State private var isPremium: Bool = true
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    @State private var showAlert: AnyAppAlert?
    
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
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .onAppear {
                setAnonymousStatus()
            }
        }
        .showCustomAlert(alert: $showAlert)
        .background(Color(uiColor: .systemBackground))
        
    }
    
    private var accountSection: some View {
        Section {
            if isAnonymousUser {
                Text("Save & back-up account")
                    .padding(.leading)
                    .rowFormatting()
                    .anyButton(.highlight) {
                        onCreateAccountPressed()
                    }
            } else {
                Text("Sign out")
                    .padding(.leading)
                    .rowFormatting()
                    .anyButton(.highlight) {
                         onSignOutPressed()
                    }
            }
           
            Text("Delete account")
                .padding(.leading)
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    onDeleteAccountPress()
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
    private func onDeleteAccountPress() {
        showAlert = AnyAppAlert(
            title: "Delete account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be deleted from our server. ",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive) {
                        onDeleteAccountConfirmed()
                    })
                
            }
        )
        
    }
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                try await authManager.deleteAccount()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    private func onSignOutPressed() {
        // do some logic to sign user out of
        Task {
            do {
                try authManager.signOut()
                await dismissScreen()
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    private func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    private func onCreateAccountPressed() {
        showCreateAccountView.toggle()
    }
    private func setAnonymousStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            
            .background(Color(uiColor: .systemBackground))
    }
}

#Preview("No auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil )))
        .environment(AppState())
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(AppState())
}

#Preview("No Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(AppState())
}
