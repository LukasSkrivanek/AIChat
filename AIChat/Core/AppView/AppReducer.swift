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

    @Dependency(\.userManager) var userManager
    @Dependency(\.authManager) var authManager
    @Dependency(\.onboardingStatus) var onboardingStatus

    @ObservableState
    struct State: Equatable {
        var isLoading = true
        var authError: String?
        var welcome = WelcomeReducer.State()
        @Presents var onboarding: OnboardingReducer.State?
        @Presents var tabBar: TabBarReducer.State?
    }

    enum Action {
        case onAppear
        case onboarding(PresentationAction<OnboardingReducer.Action>)
        case userStatusCheckSucceeded
        case userStatusCheckFailed(String)
        case welcome(WelcomeReducer.Action)
        case tabBar(PresentationAction<TabBarReducer.Action>)
    }

    var body: some Reducer<State, Action> {
        CombineReducers {
            Scope(state: \.welcome, action: \.welcome) {
                WelcomeReducer()
            }
            Reduce { state, action in
                switch action {
                case .onAppear:
                    state.isLoading = true
                    return .run { send in
                        do {
                            try await checkUserStatus()
                            await send(.userStatusCheckSucceeded)
                        } catch {
                            await send(.userStatusCheckFailed(error.localizedDescription))
                        }
                    }

                case .userStatusCheckSucceeded:
                    state.isLoading = false
                    state.authError = nil
                    state.tabBar = onboardingStatus.hasCompletedOnboarding() ? TabBarReducer.State() : nil
                    return .none

                case .userStatusCheckFailed(let errorMessage):
                    state.isLoading = false
                    state.authError = errorMessage
                    return .run { send in
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        await send(.onAppear)
                    }

                case .welcome(.delegate(.showOnboarding)):
                    state.onboarding = OnboardingReducer.State()
                    return .none

                case .welcome(.delegate(.didSignIn(let isNewUser))):
                    if isNewUser || !onboardingStatus.hasCompletedOnboarding() {
                        state.onboarding = OnboardingReducer.State()
                        state.tabBar = nil
                    } else {
                        state.onboarding = nil
                        state.tabBar = TabBarReducer.State()
                    }
                    return .none

                case .onboarding(.presented(.delegate(.didFinish))):
                    state.onboarding = nil
                    state.isLoading = true
                    return .run { send in
                        await onboardingStatus.setHasCompletedOnboarding(true)
                        await send(.onAppear)
                    }

                case .tabBar(.presented(.profile(.settings(.presented(.delegate(.didSignOut)))))),
                    .tabBar(.presented(.profile(.settings(.presented(.delegate(.didDeleteAccount)))))):
                    state.tabBar = nil
                    return .none

                case .welcome, .onboarding, .tabBar:
                    return .none
                }
            }
        }
        .ifLet(\.$onboarding, action: \.onboarding) {
            OnboardingReducer()
        }
        .ifLet(\.$tabBar, action: \.tabBar) {
            TabBarReducer()
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
}
