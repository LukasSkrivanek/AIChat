//
//  BiometricAuthClient.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import Foundation
import LocalAuthentication

struct BiometricAuthClient {
    var authenticate: @Sendable (_ reason: String) async throws -> Void
    var biometryType: @Sendable () -> BiometryType
}

extension BiometricAuthClient {
    enum BiometryType: String, Equatable, Sendable {
        case faceID
        case none
        case touchID

        var displayName: String {
            switch self {
            case .faceID:
                "Face ID"
            case .none:
                "Biometrics"
            case .touchID:
                "Touch ID"
            }
        }
    }
}

extension BiometricAuthClient: DependencyKey {
    static let liveValue = Self(
        authenticate: { reason in
            let context = LAContext()
            context.localizedCancelTitle = "Use PIN instead"

            var error: NSError?
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                throw error ?? BiometricAuthError.unavailable
            }

            try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        },
        biometryType: {
            let context = LAContext()
            var error: NSError?
            _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

            switch context.biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            default:
                return .none
            }
        }
    )

    static let testValue = Self(
        authenticate: { _ in },
        biometryType: { .none }
    )
}

extension DependencyValues {
    var biometricAuthClient: BiometricAuthClient {
        get { self[BiometricAuthClient.self] }
        set { self[BiometricAuthClient.self] = newValue }
    }
}

extension BiometricAuthClient {
    static let previewValue = Self(
        authenticate: { _ in },
        biometryType: { .faceID }
    )
}

enum BiometricAuthError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Biometric authentication is not available on this device."
        }
    }
}
