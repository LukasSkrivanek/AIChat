//
//  AppLockClient.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import CryptoKit
import Foundation
import Security

struct AppLockClient {
    var disable: @Sendable () throws -> Void
    var hasPIN: @Sendable () -> Bool
    var isBiometricUnlockEnabled: @Sendable () -> Bool
    var isEnabled: @Sendable () -> Bool
    var savePIN: @Sendable (_ pin: String) throws -> Void
    var setBiometricUnlockEnabled: @Sendable (_ isEnabled: Bool) -> Void
    var verifyPIN: @Sendable (_ pin: String) -> Bool
}

extension AppLockClient: DependencyKey {
    static let liveValue = Self(
        disable: {
            try AppLockStore.shared.disable()
        },
        hasPIN: {
            AppLockStore.shared.hasPIN
        },
        isBiometricUnlockEnabled: {
            AppLockStore.shared.isBiometricUnlockEnabled
        },
        isEnabled: {
            AppLockStore.shared.isEnabled
        },
        savePIN: { pin in
            try AppLockStore.shared.savePIN(pin)
        },
        setBiometricUnlockEnabled: { isEnabled in
            AppLockStore.shared.isBiometricUnlockEnabled = isEnabled
        },
        verifyPIN: { pin in
            AppLockStore.shared.verifyPIN(pin)
        }
    )

    static let testValue = Self(
        disable: {},
        hasPIN: { false },
        isBiometricUnlockEnabled: { false },
        isEnabled: { false },
        savePIN: { _ in },
        setBiometricUnlockEnabled: { _ in },
        verifyPIN: { _ in false }
    )
}

extension DependencyValues {
    var appLockClient: AppLockClient {
        get { self[AppLockClient.self] }
        set { self[AppLockClient.self] = newValue }
    }
}

extension AppLockClient {
    static let previewValue = Self(
        disable: {},
        hasPIN: { true },
        isBiometricUnlockEnabled: { true },
        isEnabled: { true },
        savePIN: { _ in },
        setBiometricUnlockEnabled: { _ in },
        verifyPIN: { _ in true }
    )
}

private final class AppLockStore: @unchecked Sendable {
    static let shared = AppLockStore()

    private let defaults = UserDefaults.standard
    private let service = "com.lukyskrivos.AIChat.app-lock"
    private let account = "pin-hash"
    private let biometricsKey = "app_lock_biometrics_enabled"
    private let enabledKey = "app_lock_enabled"

    var hasPIN: Bool {
        readPINHash() != nil
    }

    var isEnabled: Bool {
        defaults.bool(forKey: enabledKey) && hasPIN
    }

    var isBiometricUnlockEnabled: Bool {
        get {
            defaults.bool(forKey: biometricsKey) && isEnabled
        }
        set {
            defaults.set(newValue, forKey: biometricsKey)
        }
    }

    func disable() throws {
        defaults.set(false, forKey: enabledKey)
        defaults.set(false, forKey: biometricsKey)
        try deletePINHash()
    }

    func savePIN(_ pin: String) throws {
        try writePINHash(Self.hash(pin))
        defaults.set(true, forKey: enabledKey)
    }

    func verifyPIN(_ pin: String) -> Bool {
        guard let storedHash = readPINHash() else {
            return false
        }

        return Self.hash(pin) == storedHash
    }

    private static func hash(_ pin: String) -> String {
        let digest = SHA256.hash(data: Data(pin.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func readPINHash() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data
        else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func writePINHash(_ hash: String) throws {
        guard let data = hash.data(using: .utf8) else {
            throw AppLockStoreError.encodingFailed
        }

        let status = SecItemCopyMatching(baseQuery as CFDictionary, nil)
        if status == errSecSuccess {
            let updateStatus = SecItemUpdate(
                baseQuery as CFDictionary,
                [kSecValueData as String: data] as CFDictionary
            )
            guard updateStatus == errSecSuccess else {
                throw AppLockStoreError.keychainWriteFailed(updateStatus)
            }
        } else {
            var query = baseQuery
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw AppLockStoreError.keychainWriteFailed(addStatus)
            }
        }
    }

    private func deletePINHash() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppLockStoreError.keychainDeleteFailed(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

private enum AppLockStoreError: LocalizedError {
    case encodingFailed
    case keychainDeleteFailed(OSStatus)
    case keychainWriteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            "Could not encode the PIN."
        case .keychainDeleteFailed:
            "Could not remove the saved PIN."
        case .keychainWriteFailed:
            "Could not save the PIN."
        }
    }
}
