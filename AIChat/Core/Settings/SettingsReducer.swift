//
//  SettingsReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SettingsReducer {

    @Dependency(\.authManager) var authManager

    @ObservableState
    struct State: Equatable {
    
        @Shared(.appStorage("showTabBar"))
        var showTabBar = false
        
        var isPremium: Bool = true
        var isAnonymousUser: Bool = false
        
        @Presents
        var createAccount: CreateAccountReducer.State?
        @Presents
        var alert: AlertState<Action.Alert>?
    }

    enum Action {
        
        case onAppear
        case createAccountButtonTapped
        case signOutButtonTapped
        case deleteAccountButtonTapped
        case signOutResult(Result<Void, any Error>)
        case deleteAccountResult(Result<Void, any Error>)
        case signOutCompleted
        case deleteAccountCompleted

        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        @CasePathable
        enum Alert: Equatable {
            case deleteAccountConfirmed
        }

        @CasePathable
        enum Delegate: Equatable {
            case userSignedOut
            case userDeletedAccount
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isAnonymousUser = authManager.auth?.isAnonymous == true
                return .none

            case .createAccountButtonTapped:
                state.createAccount = CreateAccountReducer.State()
                return .none

            case .signOutButtonTapped:
                return .run { send in
                    await send(.signOutResult(Result { try authManager.signOut() }))
                }

            case .signOutResult(.success):
                state.$showTabBar.withLock { $0 = false }
                return .send(.delegate(.userSignedOut))

            case .signOutCompleted:
                return .none

            case .signOutResult(.failure(let error)):
                state.alert = AlertState { TextState("Error") } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .deleteAccountButtonTapped:
                state.alert = AlertState {
                    TextState("Delete account?")
                } actions: {
                    ButtonState(role: .destructive, action: .deleteAccountConfirmed) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This action is permanent and cannot be undone. Your data will be deleted from our server.")
                }
                return .none

            case .alert(.presented(.deleteAccountConfirmed)):
                return .run { send in
                    await send(.deleteAccountResult(Result { try await authManager.deleteAccount() }))
                }

            case .deleteAccountResult(.success):
                state.$showTabBar.withLock { $0 = false }
                return .send(.delegate(.userDeletedAccount))

            case .deleteAccountCompleted:
                return .none

            case .deleteAccountResult(.failure(let error)):
                state.alert = AlertState { TextState("Error") } message: {
                    TextState(error.localizedDescription)
                }
                return .none

            case .createAccount(.dismiss):
                state.isAnonymousUser = authManager.auth?.isAnonymous == true
                return .none

            case .alert(.dismiss):
                return .none

            case .createAccount:
                return .none

            case .alert:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
    }
}
