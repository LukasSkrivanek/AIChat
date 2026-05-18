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
        case signInButtonTapped
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signInButtonTapped:
                state.createAccount = CreateAccountReducer.State(
                    title: "Sign in",
                    subtitle: "Connect to an existing account."
                )
                return .none

            case .createAccount(.presented(.delegate(.didSignIn(let isNewUser)))):
                // TODO: handle sign in result (navigate to tabBar or onboarding)
                _ = isNewUser
                return .none

            case .createAccount:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
    }
}
