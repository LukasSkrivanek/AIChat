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
        WelcomeView(store: store.scope(state: \.welcome, action: \.welcome))
            .fullScreenCover(item: $store.scope(state: \.onboarding, action: \.onboarding)) { onboardingStore in
                OnboardingIntroView(store: onboardingStore)
            }
            .fullScreenCover(item: $store.scope(state: \.tabBar, action: \.tabBar)) { tabBarStore in
                TabBarView(store: tabBarStore)
            }
            .onAppear {
                store.send(.onAppear)
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
