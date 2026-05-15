//
//  AppvIEW.swift
//  AIChat
//
//  Created by macbook on 17.12.2024.
//

import SwiftUI
import ComposableArchitecture

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
                WelcomeView(store: store.scope(state: \.welcome, action: \.welcome))
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
