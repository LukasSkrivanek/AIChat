//
//  AppViewBuilder.swift
//  AIChat
//
//  Created by macbook on 17.12.2024.
//
import SwiftUI

struct AppViewBuilder<TabbarView: View, OnboardingView: View>: View {
    var showTabBar: Bool = false
    @ViewBuilder var tabbarView: TabbarView
    @ViewBuilder var onboardingView: OnboardingView
    var body: some View {
        ZStack {
            if showTabBar {
                ZStack {
                    Color.red.ignoresSafeArea()
                    Text("TabBar")
                }
                .transition(.move(edge: .trailing))
            } else {
                ZStack {
                    Color.blue.ignoresSafeArea()
                    Text("Onboarding")
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.smooth, value: showTabBar)
    }
}

private struct PreviewView: View {
    @State var showTabBar = false
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
        .onTapGesture {
            showTabBar.toggle()
        }
    }
}

#Preview {
    PreviewView()
}
