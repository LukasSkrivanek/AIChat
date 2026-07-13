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
        var alert: AlertState<AlertAction>?

        init(
            isDeletingAccount: Bool = false,
            isPremium: Bool = true,
            isAnonymousUser: Bool = false,
            createAccount: CreateAccountReducer.State? = nil,
            alert: AlertState<AlertAction>? = nil
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
        case signOutSucceeded
        case signOutFailed(String)
        case deleteAccountSucceeded
        case deleteAccountFailed(String)
        case delegate(DelegateAction)
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case alert(PresentationAction<AlertAction>)
    }

    @CasePathable
    enum AlertAction: Equatable {
        case deleteAccountConfirmed
        case errorDismissed
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didFinishCreateAccount
        case didDeleteAccount
        case didSignOut
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .createAccountButtonTapped:
                state.createAccount = CreateAccountReducer.State()
                return .none

            case .signOutButtonTapped:
                return .run { @MainActor send in
                    do {
                        try authManager.signOut()
                        userManager.signOut()
                        send(.signOutSucceeded)
                    } catch {
                        send(.signOutFailed(errorMessage(for: error)))
                    }
                }

            case .signOutSucceeded:
                return .send(.delegate(.didSignOut))

            case .signOutFailed(let message):
                state.alert = AlertState(
                    title: { TextState("Could not sign out") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
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
                    .run { @MainActor send in
                        do {
                            try await userManager.deleteCurrentUser()
                            try await authManager.deleteAccount()
                            send(.deleteAccountSucceeded)
                        } catch {
                            send(.deleteAccountFailed(errorMessage(for: error)))
                        }
                    }
                    .cancellable(id: CancelID.deleteAccount),

                    .run { send in
                        try await clock.sleep(for: .seconds(8))
                        await send(.deleteAccountTimedOut)
                    }
                    .cancellable(id: CancelID.deleteAccountTimeout)
                )

            case .deleteAccountSucceeded:
                state.isDeletingAccount = false
                return .merge(
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout),
                    .send(.delegate(.didDeleteAccount))
                )

            case .deleteAccountFailed(let message):
                state.isDeletingAccount = false
                state.alert = AlertState(
                    title: { TextState("Could not delete account") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
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

            case .createAccount(.presented(.delegate(.didSignIn))):
                return .send(.delegate(.didFinishCreateAccount))

            case .createAccount(.dismiss):
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
        .ifLet(\.$alert, action: \.alert)
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
