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

    @Dependency(\.userManager)
    private var userManager
    @Dependency(\.authManager)
    private var authManager

    @ObservableState
    struct AppState: Equatable {
        @Shared(.appStorage("showTabBar"))
        var showTabBar = false
        var isLoading = true
        var authError: String?
    }

    enum AppAction: Equatable {
        case onAppear
        case showTabBarChanged(Bool)
        case userStatusCheckSucceeded
        case userStatusCheckFailed(String)
    }

    var body: some Reducer<AppState, AppAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        await send(.userStatusCheckSucceeded)
                    } catch {
                        await send(.userStatusCheckFailed(error.localizedDescription))
                    }
                }
                
            case .showTabBarChanged(let showTabBar):
                if !showTabBar {
                    return .run { send in
                        do {
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
                return .none

            case .userStatusCheckFailed(let errorMessage):
                state.isLoading = false
                state.authError = errorMessage
                return .run { send in
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    await send(.onAppear)
                }
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
