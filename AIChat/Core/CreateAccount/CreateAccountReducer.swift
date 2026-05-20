//
//  CreateAccountReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 21.03.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CreateAccountReducer {

    @Dependency(\.authManager) var authManager
    @Dependency(\.userManager) var userManager
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    struct State: Equatable {
        var title: String = "Create Account"
        var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
        var isLoading = false
        @Presents var alert: AlertState<AlertAction>?
    }

    enum Action {
        case signInAppleButtonTapped
        case signInAppleSucceeded(isNewUser: Bool)
        case signInAppleFailed(String)
        case alert(PresentationAction<AlertAction>)
        case delegate(DelegateAction)
    }

    @CasePathable
    enum AlertAction: Equatable {
        case dismiss
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didSignIn(isNewUser: Bool)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signInAppleButtonTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        let result = try await authManager.signInApple()
                        try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                        await send(.signInAppleSucceeded(isNewUser: result.isNewUser))
                    } catch {
                        await send(.signInAppleFailed(errorMessage(for: error)))
                    }
                }

            case .signInAppleSucceeded(let isNewUser):
                state.isLoading = false
                return .run { send in
                    await send(.delegate(.didSignIn(isNewUser: isNewUser)))
                    await dismiss()
                }

            case .signInAppleFailed(let message):
                state.isLoading = false
                state.alert = AlertState(
                    title: { TextState("Sign in failed") },
                    actions: {
                        ButtonState(action: .dismiss) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
                    }
                )
                return .none

            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension CreateAccountReducer {
    private func errorMessage(for error: any Error) -> String {
        switch error {
        case let error as AuthServiceError:
            error.errorDescription ?? "Something went wrong."
        case let error as UserServiceError:
            error.errorDescription ?? "Something went wrong."
        default:
            error.localizedDescription
        }
    }
}
