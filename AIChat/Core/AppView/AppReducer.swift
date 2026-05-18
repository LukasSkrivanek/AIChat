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

    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("showTabBar"))
        var showTabBar = false
        var isLoading = true
        var authError: String?
        var welcome = WelcomeReducer.State()
        @Presents var tabBar: TabBarReducer.State?
    }

    enum Action {
        case onAppear
        case showTabBarChanged(Bool)
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

                case .showTabBarChanged(let showTabBar):
                    if showTabBar {
                        state.tabBar = TabBarReducer.State()
                    } else {
                        state.tabBar = nil
                        return .run { send in
                            do {
                                try await checkUserStatus()
                                await send(.userStatusCheckSucceeded)
                            } catch {
                                await send(.userStatusCheckFailed(error.localizedDescription))
                            }
                        }
                    }
                    return .none

                case .userStatusCheckSucceeded:
                    state.isLoading = false
                    state.authError = nil
                    if state.showTabBar {
                        state.tabBar = TabBarReducer.State()
                    } else {
                        state.tabBar = nil
                    }
                    return .none

                case .userStatusCheckFailed(let errorMessage):
                    state.isLoading = false
                    state.authError = errorMessage
                    return .run { send in
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        await send(.onAppear)
                    }

                case .welcome, .tabBar:
                    return .none
                }
            }
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
