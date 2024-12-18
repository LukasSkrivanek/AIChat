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
    @AppStorage("showTabBar") var showTabBar = true
    var body: some View {
        AppViewBuilder(showTabBar: showTabBar,
                       tabbarView: {
            TabBarView()
        }, onboardingView: {
            WelcomeView()
        })
    }
}

#Preview("AppView - TabBar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}
