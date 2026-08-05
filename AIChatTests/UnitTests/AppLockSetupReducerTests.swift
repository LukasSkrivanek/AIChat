//
//  AppLockSetupReducerTests.swift
//  AIChatTests
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import AIChat

@Suite("AppLockSetupReducer tests")
struct AppLockSetupReducerTests {

    @Test
    func savePersistsPINAndSendsDelegate() async {
        let savedPIN = Box<String?>(nil)
        let biometricEnabled = Box(false)

        let store = TestStore(
            initialState: AppLockSetupReducer.State(
                confirmationPIN: "1234",
                isBiometricAvailable: true,
                isBiometricEnabled: true,
                mode: .changePIN,
                primaryPIN: "1234"
            )
        ) {
            AppLockSetupReducer()
        } withDependencies: {
            $0.appLockClient = AppLockClient(
                disable: {},
                hasPIN: { false },
                isBiometricUnlockEnabled: { false },
                isEnabled: { false },
                savePIN: { pin in
                    savedPIN.value = pin
                },
                setBiometricUnlockEnabled: { isEnabled in
                    biometricEnabled.value = isEnabled
                },
                verifyPIN: { _ in false }
            )
        }

        await store.send(AppLockSetupReducer.Action.saveButtonTapped)
        await store.receive(.delegate(.didSave))

        #expect(savedPIN.value == "1234")
        #expect(biometricEnabled.value)
    }

    @Test
    func saveWithMismatchedPINShowsError() async {
        let store = TestStore(
            initialState: AppLockSetupReducer.State(
                activeEntry: .confirmation,
                confirmationPIN: "1111",
                primaryPIN: "1234"
            )
        ) {
            AppLockSetupReducer()
        }

        await store.send(AppLockSetupReducer.Action.saveButtonTapped) {
            $0.confirmationPIN = ""
            $0.errorMessage = "PINs do not match."
        }
    }

    @Test
    func enablingBiometricsAuthenticatesImmediately() async {
        let store = TestStore(
            initialState: AppLockSetupReducer.State(
                isBiometricAvailable: true
            )
        ) {
            AppLockSetupReducer()
        } withDependencies: {
            $0.biometricAuthClient = BiometricAuthClient(
                authenticate: { _ in },
                biometryType: { .faceID }
            )
        }

        await store.send(.binding(.set(\.isBiometricEnabled, true))) {
            $0.isBiometricEnabled = true
        }
        await store.receive(.biometricAuthenticationResponse(.success(())))
    }

    @Test
    func failedBiometricAuthTurnsToggleBackOff() async {
        struct TestError: LocalizedError {
            var errorDescription: String? { "Face ID failed." }
        }

        let store = TestStore(
            initialState: AppLockSetupReducer.State(
                isBiometricAvailable: true
            )
        ) {
            AppLockSetupReducer()
        } withDependencies: {
            $0.biometricAuthClient = BiometricAuthClient(
                authenticate: { _ in throw TestError() },
                biometryType: { .faceID }
            )
        }

        await store.send(.binding(.set(\.isBiometricEnabled, true))) {
            $0.isBiometricEnabled = true
        }
        await store.receive(.biometricAuthenticationResponse(.failure(TestError()))) {
            $0.isBiometricEnabled = false
            $0.errorMessage = "Face ID failed."
        }
    }
}

private final class Box<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}
