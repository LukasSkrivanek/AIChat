//
//  AppvIEW.swift
//  AIChat
//
//  Created by macbook on 17.12.2024.
//

import SwiftUI
// tabbar - signed in
// onboarding - signed out

struct AppView: View {
    @State var appState: AppState = AppState()
    var body: some View {
        AppViewBuilder(showTabBar: appState.showTabBar,
                       tabbarView: {
            TabBarView()
        }, onboardingView: {
            WelcomeView()
        })
        .environment(appState)
    }
}

#Preview("AppView - TabBar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
