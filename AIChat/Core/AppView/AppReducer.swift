//
//  AppReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 17.03.2026.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppReducer {

    @Reducer
    enum Destination {
        case launching
        case onboarding(OnboardingReducer)
        case tabBar(TabBarReducer)
        case welcome(WelcomeReducer)
    }

    @Dependency(\.userManager)
    var userManager
    @Dependency(\.authManager)
    var authManager

    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .launching
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case destination(Destination.Action)
        case onAppear
        case refreshSession
        case userStatusCheckSucceeded
        case userStatusCheckFailed(String)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert: Equatable {
            case retryTapped
            case dismissTapped
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce { state, action in
            switch action {
            case .onAppear, .refreshSession:
                state.destination = .launching
                return .run { send in
                    do {
                        try await checkUserStatus()
                        await send(.userStatusCheckSucceeded)
                    } catch {
                        await send(.userStatusCheckFailed(errorMessage(for: error)))
                    }
                }

            case .userStatusCheckSucceeded:
                state.alert = nil
                state.destination = hasCompletedOnboarding()
                    ? .tabBar(TabBarReducer.State())
                    : .onboarding(OnboardingReducer.State())
                return .none

            case .userStatusCheckFailed(let errorMessage):
                state.destination = .welcome(WelcomeReducer.State())
                state.alert = AlertState(
                    title: { TextState("Could not start app") },
                    actions: {
                        ButtonState(role: .cancel, action: .dismissTapped) {
                            TextState("OK")
                        }
                        ButtonState(action: .retryTapped) {
                            TextState("Try again")
                        }
                    },
                    message: {
                        TextState(errorMessage)
                    }
                )
                return .none

            case .alert(.presented(.retryTapped)):
                state.alert = nil
                return .send(.refreshSession)

            case .alert(.presented(.dismissTapped)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                return .none

            case .destination(.welcome(.delegate(.showOnboarding))):
                state.destination = .onboarding(OnboardingReducer.State())
                return .none

            case .destination(.welcome(.delegate(.didSignIn(let isNewUser)))):
                state.destination = authenticatedDestination(isNewUser: isNewUser)
                return .none

            case .destination(.onboarding(.delegate(.didFinish))):
                state.destination = .tabBar(TabBarReducer.State())
                return .none

            case .destination(.tabBar(.profile(.delegate(.didSignOut)))),
                 .destination(.tabBar(.profile(.delegate(.didDeleteAccount)))):
                return .send(.refreshSession)

            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Private Methods
    private func checkUserStatus() async throws {
        if let user = authManager.auth {
            print("User is authenticated: \(user.uId)")
            try await userManager.logIn(auth: user, isNewUser: false)
        } else {
            let result = try await authManager.signInAnonymously()
            print("Sign in anonymously: \(result.user.uId)")
            try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
        }
    }

    private func hasCompletedOnboarding() -> Bool {
        userManager.currentUser?.didCompleteOnboarding == true
    }

    private func authenticatedDestination(isNewUser: Bool = false) -> Destination.State {
        if isNewUser || !hasCompletedOnboarding() {
            return .onboarding(OnboardingReducer.State())
        } else {
            return .tabBar(TabBarReducer.State())
        }
    }
}

extension AppReducer {
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

extension AppReducer.Destination.State: Equatable, Sendable {}
