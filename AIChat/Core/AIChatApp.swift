//
//  AIChatApp.swift
//  AIChat
//
//  Created by macbook on 16.12.2024.
//

import SwiftUI
import Firebase
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let store = Store(
        initialState: AppReducer.State(),
        reducer: {
            AppReducer()
        }
    )

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
