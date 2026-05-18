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
        case delegate(Delegate)
        case getStartedButtonTapped
        case signInButtonTapped
        case createAccount(PresentationAction<CreateAccountReducer.Action>)

        @CasePathable
        enum Delegate: Equatable {
            case didSignIn(isNewUser: Bool)
            case showOnboarding
        }
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

            case .createAccount(.presented(.delegate(.didSignIn(let isNewUser)))):
                return .send(.delegate(.didSignIn(isNewUser: isNewUser)))

            case .createAccount, .delegate:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
    }
}
