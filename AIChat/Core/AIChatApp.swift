//
//  AIChatApp.swift
//  AIChat
//
//  Created by macbook on 16.12.2024.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
struct EnvironmentBuilderView<Content:View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .environment(AuthManager(service: FirebaseAuthService()))
    }
}
@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            EnvironmentBuilderView {
                AppView()
            }
      
        }
    }
}
