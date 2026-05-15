//
//  CreateAccountReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 21.03.2026.
//

import ComposableArchitecture

@Reducer
struct CreateAccountReducer {

    @Dependency(\.authManager) var authManager
    @Dependency(\.dismiss) var dismiss

    @ObservableState
    struct State: Equatable {
        var title: String = "Create Account"
        var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
        var isLoading = false
    }

    enum Action: Equatable {
        case signInAppleButtonTapped
        case signInAppleSucceeded(isNewUser: Bool)
        case signInAppleFailed(String)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case didSignIn(isNewUser: Bool)
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signInAppleButtonTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        let result = try await authManager.signInApple()
                        await send(.signInAppleSucceeded(isNewUser: result.isNewUser))
                    } catch {
                        await send(.signInAppleFailed(error.localizedDescription))
                    }
                }

            case .signInAppleSucceeded(let isNewUser):
                state.isLoading = false
                return .run { send in
                    await send(.delegate(.didSignIn(isNewUser: isNewUser)))
                    await dismiss()
                }

            case .signInAppleFailed:
                state.isLoading = false
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
