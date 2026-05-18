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
    @Dependency(\.userManager) var userManager

    @ObservableState
    struct State: Equatable {
        var isPremium: Bool = true
        var isAnonymousUser: Bool = false

        @Presents
        var createAccount: CreateAccountReducer.State?
        @Presents
        var alert: AlertState<Action.Alert>?

        init(
            isPremium: Bool = true,
            isAnonymousUser: Bool = false,
            createAccount: CreateAccountReducer.State? = nil,
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.isPremium = isPremium
            self.isAnonymousUser = isAnonymousUser
            self.createAccount = createAccount
            self.alert = alert
        }
    }

    enum Action {
        case createAccountButtonTapped
        case signOutButtonTapped
        case deleteAccountButtonTapped
        case signOutResult(Result<Void, any Error>)
        case deleteAccountResult(Result<Void, any Error>)
        case delegate(Delegate)

        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert: Equatable {
            case deleteAccountConfirmed
        }

        @CasePathable
        enum Delegate: Equatable {
            case didDeleteAccount
            case didSignOut
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .createAccountButtonTapped:
                state.createAccount = CreateAccountReducer.State()
                return .none

            case .signOutButtonTapped:
                return .run { send in
                    await send(
                        .signOutResult(
                            Result {
                                try authManager.signOut()
                                userManager.signOut()
                            }
                        )
                    )
                }

            case .signOutResult(.success):
                return .send(.delegate(.didSignOut))

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
                state.alert = nil
                return .run { send in
                    await send(
                        .deleteAccountResult(
                            Result {
                                try await userManager.deleteCurrentUser()
                                try await authManager.deleteAccount()
                            }
                        )
                    )
                }

            case .deleteAccountResult(.success):
                return .send(.delegate(.didDeleteAccount))

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

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
    }
}
