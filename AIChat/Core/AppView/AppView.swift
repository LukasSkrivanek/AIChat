//
//  AppvIEW.swift
//  AIChat
//
//  Created by macbook on 17.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {

    @Bindable var store: StoreOf<AppReducer>
    private let deepLinkParser = DeepLinkParser()

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
        .onOpenURL { url in
            guard let deepLink = deepLinkParser.parse(url) else {
                return
            }

            store.send(.deepLink(deepLink))
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
