//
//  AppUnlockReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppUnlockReducer {

    @Dependency(\.appLockClient)
    var appLockClient
    @Dependency(\.biometricAuthClient)
    var biometricAuthClient

    @ObservableState
    struct State: Equatable {
        var errorMessage: String?
        var isAuthenticating = false
        var isBiometricUnlockEnabled = false
        var pin = ""
        var supportedBiometry: BiometricAuthClient.BiometryType = .none

        var biometricButtonTitle: String {
            "Use \(supportedBiometry.displayName)"
        }

        var isBiometricAvailable: Bool {
            supportedBiometry != .none
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case biometricAuthenticationResponse(Result<Void, any Error>)
        case biometricButtonTapped
        case delegate(DelegateAction)
        case task
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didUnlock
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.pin):
                state.errorMessage = nil
                state.pin = sanitizedPIN(state.pin)

                guard state.pin.count == 4 else {
                    return .none
                }

                if appLockClient.verifyPIN(state.pin) {
                    state.pin = ""
                    return .send(.delegate(.didUnlock))
                } else {
                    state.pin = ""
                    state.errorMessage = "Wrong PIN. Try again."
                    return .none
                }

            case .binding:
                return .none

            case .task:
                guard state.isBiometricUnlockEnabled, state.isBiometricAvailable else {
                    return .none
                }
                return authenticateWithBiometrics(&state)

            case .biometricButtonTapped:
                guard state.isBiometricAvailable else {
                    return .none
                }
                return authenticateWithBiometrics(&state)

            case .biometricAuthenticationResponse(.success):
                state.isAuthenticating = false
                return .send(.delegate(.didUnlock))

            case .biometricAuthenticationResponse(.failure(let error)):
                state.isAuthenticating = false
                state.errorMessage = errorMessage(for: error)
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func authenticateWithBiometrics(
        _ state: inout State
    ) -> Effect<Action> {
        guard !state.isAuthenticating else {
            return .none
        }

        state.isAuthenticating = true
        state.errorMessage = nil

        return .run { send in
            await send(
                .biometricAuthenticationResponse(
                    Result {
                        try await biometricAuthClient.authenticate("Unlock AIChat")
                    }
                )
            )
        }
    }

    private func errorMessage(for error: any Error) -> String {
        if let biometricError = error as? BiometricAuthError {
            return biometricError.localizedDescription
        }

        return error.localizedDescription
    }

    private func sanitizedPIN(_ value: String) -> String {
        String(value.filter(\.isNumber).prefix(4))
    }
}

extension AppUnlockReducer.Action: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.binding(let lhs), .binding(let rhs)):
            return lhs == rhs
        case (.biometricAuthenticationResponse(.success), .biometricAuthenticationResponse(.success)):
            return true
        case (
            .biometricAuthenticationResponse(.failure(let lhsError)),
            .biometricAuthenticationResponse(.failure(let rhsError))
        ):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.biometricButtonTapped, .biometricButtonTapped):
            return true
        case (.delegate(let lhs), .delegate(let rhs)):
            return lhs == rhs
        case (.task, .task):
            return true
        default:
            return false
        }
    }
}
