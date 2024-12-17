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
    @AppStorage("showTabBar") var showTabBar = false
    var body: some View {
        AppViewBuilder(showTabBar: showTabBar,
                       tabbarView: {
            ZStack {
                Color.red.ignoresSafeArea()
                Text("TabBar")
            }
        }, onboardingView: {
            ZStack {
                Color.blue.ignoresSafeArea()
                Text("Onboarding")
            }
        })
    }
}

#Preview("AppView - TabBar") {
    AppView(showTabBar: true)
}

#Preview("AppView - Onboarding") {
    AppView(showTabBar: false)
}
