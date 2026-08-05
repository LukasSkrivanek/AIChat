//
//  AppUnlockReducerTests.swift
//  AIChatTests
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import Testing
@testable import AIChat

@Suite("AppUnlockReducer tests")
struct AppUnlockReducerTests {

    @Test
    func enteringCorrectPINUnlocksApp() async {
        let store = TestStore(
            initialState: AppUnlockReducer.State()
        ) {
            AppUnlockReducer()
        } withDependencies: {
            $0.appLockClient = AppLockClient(
                disable: {},
                hasPIN: { true },
                isBiometricUnlockEnabled: { false },
                isEnabled: { true },
                savePIN: { _ in },
                setBiometricUnlockEnabled: { _ in },
                verifyPIN: { $0 == "1234" }
            )
        }

        await store.send(.binding(.set(\.pin, "1234"))) {
            $0.pin = ""
        }
        await store.receive(.delegate(.didUnlock))
    }

    @Test
    func enteringWrongPINShowsError() async {
        let store = TestStore(
            initialState: AppUnlockReducer.State()
        ) {
            AppUnlockReducer()
        } withDependencies: {
            $0.appLockClient = AppLockClient(
                disable: {},
                hasPIN: { true },
                isBiometricUnlockEnabled: { false },
                isEnabled: { true },
                savePIN: { _ in },
                setBiometricUnlockEnabled: { _ in },
                verifyPIN: { _ in false }
            )
        }

        await store.send(.binding(.set(\.pin, "0000"))) {
            $0.pin = ""
            $0.errorMessage = "Wrong PIN. Try again."
        }
    }
}
