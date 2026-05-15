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
        case welcome(WelcomeReducer)
        case tabBar(TabBarReducer)
    }

    @Dependency(\.userManager)
    var userManager
    @Dependency(\.authManager)
    var authManager

    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("showTabBar"))
        var showTabBar = false
        var isLoading = true
        var authError: String?
        var destination: Destination.State = .welcome(WelcomeReducer.State())
    }

    enum Action {
        case onAppear
        case showTabBarChanged(Bool)
        case userStatusCheckSucceeded
        case userStatusCheckFailed(String)
        case destination(Destination.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
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

            case .showTabBarChanged(let showTabBar):
                if showTabBar {
                    state.destination = .tabBar(TabBarReducer.State())
                }
                return .none

            case .destination(.tabBar(.delegate(.userSignedOut))),
                 .destination(.tabBar(.delegate(.userDeletedAccount))):
                state.destination = .welcome(WelcomeReducer.State())
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
                state.destination = state.showTabBar
                    ? .tabBar(TabBarReducer.State())
                    : .welcome(WelcomeReducer.State())
                return .none

            case .userStatusCheckFailed(let errorMessage):
                state.isLoading = false
                state.authError = errorMessage
                return .run { send in
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    await send(.onAppear)
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
}

extension AppReducer.Destination.State: Equatable {}
