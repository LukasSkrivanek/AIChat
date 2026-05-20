//
//  SettingsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//
import SwiftUI
import ComposableArchitecture

struct SettingsView: View {

    @Bindable var store: StoreOf<SettingsReducer>

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
            .sheet(item: $store.scope(state: \.createAccount, action: \.createAccount)) { createAccountStore in
                CreateAccountView(store: createAccountStore)
                    .presentationDetents([.medium])
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .overlay {
            if store.isDeletingAccount {
                ZStack {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    ProgressView("Deleting account…")
                        .padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
    
    private var accountSection: some View {
        Section {
            if store.isAnonymousUser {
                Text("Save & back-up account")
                    .padding(.leading)
                    .rowFormatting()
                    .anyButton(.highlight) {
                        store.send(.createAccountButtonTapped)
                    }
            } else {
                Text("Sign out")
                    .padding(.leading)
                    .rowFormatting()
                    .anyButton(.highlight) {
                        store.send(.signOutButtonTapped)
                    }
            }

            Text("Delete account")
                .padding(.leading)
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    store.send(.deleteAccountButtonTapped)
                }
        } header: {
            Text("Account")
        }
        .disabled(store.isDeletingAccount)
    }
    private var purchaseSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(store.isPremium ? "Premium" : "Free")")
                    .padding(.leading)
                Spacer(minLength: 0)
                if store.isPremium {
                    Text("MANAGE")
                        .badgeButton()
                        .padding(.trailing)
                }
            }
                .rowFormatting()
                .anyButton(.highlight) {
                
                }
                .disabled(!store.isPremium)
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
    SettingsView(
        store: Store(initialState: SettingsReducer.State(isAnonymousUser: false)) {
            SettingsReducer()
        }
    )
}

#Preview("Anonymous") {
    SettingsView(
        store: Store(initialState: SettingsReducer.State(isAnonymousUser: true)) {
            SettingsReducer()
        }
    )
}

#Preview("No Anonymous") {
    SettingsView(
        store: Store(initialState: SettingsReducer.State(isAnonymousUser: false)) {
            SettingsReducer()
        }
    )
}
