//
//  OnboardingStatusClient.swift
//  AIChat
//
//  Created by OpenAI Codex on 17.05.2026.
//

import ComposableArchitecture
import Foundation

struct OnboardingStatusClient {
    var hasCompletedOnboarding: @Sendable () -> Bool
    var setHasCompletedOnboarding: @Sendable (Bool) async -> Void
}

private enum OnboardingStatusKey: DependencyKey {
    static let liveValue = OnboardingStatusClient(
        hasCompletedOnboarding: {
            UserDefaults.standard.bool(forKey: "did_complete_onboarding")
        },
        setHasCompletedOnboarding: { value in
            UserDefaults.standard.set(value, forKey: "did_complete_onboarding")
        }
    )
}

extension DependencyValues {
    var onboardingStatus: OnboardingStatusClient {
        get { self[OnboardingStatusKey.self] }
        set { self[OnboardingStatusKey.self] = newValue }
    }
}
