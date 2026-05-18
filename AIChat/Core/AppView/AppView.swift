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
    static let liveValue = AuthManager(service: FirebaseAuthService())
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
        Group {
            switch store.destination {
            case .launching:
                ProgressView()

            case .welcome:
                if let welcomeStore = store.scope(
                    state: \.destination.welcome,
                    action: \.destination.welcome
                ) {
                    WelcomeView(store: welcomeStore)
                }

            case .onboarding:
                if let onboardingStore = store.scope(
                    state: \.destination.onboarding,
                    action: \.destination.onboarding
                ) {
                    OnboardingIntroView(store: onboardingStore)
                }

            case .tabBar:
                if let tabBarStore = store.scope(
                    state: \.destination.tabBar,
                    action: \.destination.tabBar
                ) {
                    TabBarView(store: tabBarStore)
                }
            }
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
