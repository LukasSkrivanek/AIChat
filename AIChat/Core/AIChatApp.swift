//
//  AIChatApp.swift
//  AIChat
//
//  Created by macbook on 16.12.2024.
//

import SwiftUI
import Firebase
import FirebaseAuth
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        application.registerForRemoteNotifications()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard Auth.auth().canHandleNotification(userInfo) else {
            completionHandler(.noData)
            return
        }

        completionHandler(.noData)
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
