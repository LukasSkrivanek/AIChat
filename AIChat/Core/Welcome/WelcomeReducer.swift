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
        @Presents var onboarding: OnboardingReducer.State?
    }

    enum Action {
        case getStartedButtonTapped
        case signInButtonTapped
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case onboarding(PresentationAction<OnboardingReducer.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getStartedButtonTapped:
                state.onboarding = OnboardingReducer.State()
                return .none

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

            case .createAccount, .onboarding:
                return .none
            }
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
        .ifLet(\.$onboarding, action: \.onboarding) {
            OnboardingReducer()
        }
    }
}
