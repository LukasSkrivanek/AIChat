//
//  AppvIEW.swift
//  AIChat
//
//  Created by macbook on 17.12.2024.
//

import SwiftUI
import ComposableArchitecture
// tabbar - signed in
// onboarding - signed out

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
                
                // Pokud se uživatel odhlásí, znovu kontrolujeme status
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

extension UserManager: DependencyKey {
    static let liveValue = UserManager(service: FirebaseUserService())
}

extension DependencyValues {
    var userManager: UserManager {
        get { self[UserManager.self] }
        set { self[UserManager.self] = newValue }
    }
}

extension AuthManager: DependencyKey {
    static let liveValue = AuthManager(service: MockAuthService())
}

extension DependencyValues {
    var authManager: AuthManager {
        get { self[AuthManager.self] }
        set { self[AuthManager.self] = newValue }
    }
}

struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        AppViewBuilder(
            showTabBar: store.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.showTabBar) { _, showTabBar in
            store.send(.showTabBarChanged(showTabBar))
        }
        .overlay {
            if let error = store.authError {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
            }
        }
    }
}
