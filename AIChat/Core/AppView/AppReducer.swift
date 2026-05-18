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

    @Reducer(state: .equatable)
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
        var authError: String?
        var destination: Destination.State = .launching
    }

    enum Action {
        case destination(Destination.Action)
        case onAppear
        case userStatusCheckSucceeded
        case userStatusCheckFailed(String)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.destination = .launching
                return .run { send in
                    do {
                        try await checkUserStatus()
                        await send(.userStatusCheckSucceeded)
                    } catch {
                        await send(.userStatusCheckFailed(error.localizedDescription))
                    }
                }

            case .userStatusCheckSucceeded:
                state.authError = nil
                state.destination = hasCompletedOnboarding()
                    ? .tabBar(TabBarReducer.State())
                    : .welcome(WelcomeReducer.State())
                return .none

            case .userStatusCheckFailed(let errorMessage):
                state.authError = errorMessage
                state.destination = .welcome(WelcomeReducer.State())
                return .run { send in
                    await send(.onAppear)
                }

            case .destination(.welcome(.delegate(.showOnboarding))):
                state.destination = .onboarding(OnboardingReducer.State())
                return .none

            case .destination(.welcome(.delegate(.didSignIn(let isNewUser)))):
                if isNewUser || !hasCompletedOnboarding() {
                    state.destination = .onboarding(OnboardingReducer.State())
                } else {
                    state.destination = .tabBar(TabBarReducer.State())
                }
                return .none

            case .destination(.onboarding(.delegate(.didFinish))):
                state.destination = .tabBar(TabBarReducer.State())
                return .none

            case .destination(.tabBar(.profile(.delegate(.didSignOut)))):
                state.destination = .launching
                return .run { send in
                    do {
                        try await checkUserStatus()
                        await send(.userStatusCheckSucceeded)
                    } catch {
                        await send(.userStatusCheckFailed(error.localizedDescription))
                    }
                }

            case .destination(.tabBar(.profile(.delegate(.didDeleteAccount)))):
                state.destination = .launching
                return .run { send in
                    do {
                        try await checkUserStatus()
                        await send(.userStatusCheckSucceeded)
                    } catch {
                        await send(.userStatusCheckFailed(error.localizedDescription))
                    }
                }

            case .destination:
                return .none
            }
        }
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
}
