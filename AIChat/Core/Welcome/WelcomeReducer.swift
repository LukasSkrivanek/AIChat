//
//  WelcomeReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 21.03.2026.
//

import ComposableArchitecture

@Reducer
struct WelcomeReducer {

    @ObservableState
    struct State: Equatable {
        @Presents var createAccount: CreateAccountReducer.State?
    }

    enum Action {
        case delegate(DelegateAction)
        case getStartedButtonTapped
        case signInButtonTapped
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didSignIn(isNewUser: Bool, didCompleteOnboarding: Bool)
        case showOnboarding
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getStartedButtonTapped:
                return .send(.delegate(.showOnboarding))

            case .signInButtonTapped:
                state.createAccount = CreateAccountReducer.State(
                    title: "Sign in",
                    subtitle: "Connect to an existing account."
                )
                return .none

            case .createAccount(.presented(.delegate(.didSignIn(let isNewUser, let didCompleteOnboarding)))):
                return .send(
                    .delegate(
                        .didSignIn(
                            isNewUser: isNewUser,
                            didCompleteOnboarding: didCompleteOnboarding
                        )
                    )
                )

            case .createAccount, .delegate:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
    }
}
