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

    nonisolated private enum CancelID: Hashable, Sendable {
        case deleteAccount
        case deleteAccountTimeout
    }

    @Dependency(\.continuousClock)
    var clock
    @Dependency(\.authManager)
    var authManager
    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        var isDeletingAccount = false
        var isPremium: Bool = true
        var isAnonymousUser: Bool = false

        @Presents
        var createAccount: CreateAccountReducer.State?
        @Presents
        var alert: AlertState<Action.Alert>?

        init(
            isDeletingAccount: Bool = false,
            isPremium: Bool = true,
            isAnonymousUser: Bool = false,
            createAccount: CreateAccountReducer.State? = nil,
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.isDeletingAccount = isDeletingAccount
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
        case deleteAccountTimedOut
        case signOutResult(Result<Void, any Error>)
        case deleteAccountResult(Result<Void, any Error>)
        case delegate(Delegate)
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert: Equatable {
            case deleteAccountConfirmed
            case errorDismissed
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
                state.alert = AlertState(
                    title: { TextState("Could not sign out") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
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
                state.isDeletingAccount = true
                return .merge(
                    .run { send in
                        await send(
                            .deleteAccountResult(
                                Result {
                                    try await userManager.deleteCurrentUser()
                                    try await authManager.deleteAccount()
                                }
                            )
                        )
                    }
                    .cancellable(id: CancelID.deleteAccount),

                    .run { send in
                        try await clock.sleep(for: .seconds(8))
                        await send(.deleteAccountTimedOut)
                    }
                    .cancellable(id: CancelID.deleteAccountTimeout)
                )

            case .deleteAccountResult(.success):
                state.isDeletingAccount = false
                return .merge(
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout),
                    .send(.delegate(.didDeleteAccount))
                )

            case .deleteAccountResult(.failure(let error)):
                state.isDeletingAccount = false
                state.alert = AlertState(
                    title: { TextState("Could not delete account") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .merge(
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout)
                )

            case .deleteAccountTimedOut:
                state.isDeletingAccount = false
                state.alert = AlertState(
                    title: { TextState("Could not delete account") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: SettingsError.deleteTimedOut))
                    }
                )
                return .merge(
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout)
                )

            case .alert(.presented(.errorDismissed)):
                state.alert = nil
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

extension SettingsReducer {
    private enum SettingsError: LocalizedError {
        case deleteTimedOut

        var errorDescription: String? {
            switch self {
            case .deleteTimedOut:
                "You're offline or the request took too long. Please reconnect and try again."
            }
        }
    }

    private func errorMessage(for error: any Error) -> String {
        switch error {
        case let error as SettingsError:
            error.errorDescription ?? "Something went wrong."
        case let error as AuthServiceError:
            error.errorDescription ?? "Something went wrong."
        case let error as UserServiceError:
            error.errorDescription ?? "Something went wrong."
        default:
            error.localizedDescription
        }
    }
}
