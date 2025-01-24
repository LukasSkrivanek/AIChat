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
    @Environment(\.authService) private var authService
    @State var appState: AppState = AppState()
    var body: some View {
        AppViewBuilder(showTabBar: appState.showTabBar,
                       tabbarView: {
            TabBarView()
        }, onboardingView: {
            WelcomeView()
        })
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
        
    }
    private func checkUserStatus() async {
        if let user  = authService.getAuthenticatedUser() {
            // User is authenticated
            print("User is authenticated: \(user.uId)")
        } else {
            // User is not authenticated
            do {
               let result =  try await authService.signInAnonymously()
                // log in to app
                print("Sign in anonymously: \(result.user.uId)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("AppView - TabBar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
