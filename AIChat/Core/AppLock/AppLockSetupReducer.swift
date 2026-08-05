//
//  AppLockSetupReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppLockSetupReducer {

    @Dependency(\.appLockClient)
    var appLockClient
    @Dependency(\.biometricAuthClient)
    var biometricAuthClient

    @ObservableState
    struct State: Equatable {
        enum Mode: Equatable {
            case changePIN
            case setup
        }

        var activeEntry: PINEntry = .primary
        var confirmationPIN = ""
        var errorMessage: String?
        var isBiometricAvailable = false
        var isBiometricEnabled = false
        var mode: Mode = .setup
        var primaryPIN = ""

        var biometricToggleTitle: String {
            "Unlock with Face ID / Touch ID"
        }

        var shouldShowBiometricToggle: Bool {
            mode == .changePIN && isBiometricAvailable
        }

        var activePIN: String {
            switch activeEntry {
            case .primary:
                primaryPIN
            case .confirmation:
                confirmationPIN
            }
        }

        var primaryTitle: String {
            "Enter PIN"
        }

        var confirmationTitle: String {
            "Confirm PIN"
        }

        var title: String {
            switch mode {
            case .changePIN:
                "Change PIN"
            case .setup:
                "Set up App Lock"
            }
        }

        var headerTitle: String {
            switch mode {
            case .changePIN:
                "Change your 4-digit PIN"
            case .setup:
                "Create a 4-digit PIN"
            }
        }

        var headerMessage: String {
            switch mode {
            case .changePIN:
                "Enter and confirm a new PIN for this device."
            case .setup:
                "This PIN is used to unlock the app on this device."
            }
        }
    }

    enum PINEntry: Equatable {
        case primary
        case confirmation
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case biometricAuthenticationResponse(Result<Void, any Error>)
        case cancelButtonTapped
        case deleteButtonTapped
        case delegate(DelegateAction)
        case digitTapped(String)
        case entryTapped(PINEntry)
        case saveButtonTapped
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didCancel
        case didSave
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.primaryPIN):
                state.errorMessage = nil
                state.primaryPIN = sanitizedPIN(state.primaryPIN)
                return .none

            case .binding(\.confirmationPIN):
                state.errorMessage = nil
                state.confirmationPIN = sanitizedPIN(state.confirmationPIN)
                return .none

            case .binding(\.isBiometricEnabled):
                state.errorMessage = nil

                guard state.isBiometricAvailable else {
                    state.isBiometricEnabled = false
                    return .none
                }

                guard state.isBiometricEnabled else {
                    return .none
                }

                return .run { send in
                    await send(
                        .biometricAuthenticationResponse(
                            Result {
                                try await biometricAuthClient.authenticate(
                                    "Enable biometric unlock for AIChat"
                                )
                            }
                        )
                    )
                }

            case .binding:
                return .none

            case .cancelButtonTapped:
                return .send(.delegate(.didCancel))

            case .entryTapped(let entry):
                state.activeEntry = entry
                state.errorMessage = nil
                return .none

            case .digitTapped(let digit):
                state.errorMessage = nil
                guard state.activePIN.count < 4 else {
                    return .none
                }

                switch state.activeEntry {
                case .primary:
                    state.primaryPIN = sanitizedPIN(state.primaryPIN + digit)
                    if state.primaryPIN.count == 4 {
                        state.activeEntry = .confirmation
                    }
                case .confirmation:
                    state.confirmationPIN = sanitizedPIN(state.confirmationPIN + digit)
                }
                return .none

            case .deleteButtonTapped:
                state.errorMessage = nil
                switch state.activeEntry {
                case .primary:
                    state.primaryPIN = String(state.primaryPIN.dropLast())
                case .confirmation:
                    if state.confirmationPIN.isEmpty {
                        state.activeEntry = .primary
                        state.primaryPIN = String(state.primaryPIN.dropLast())
                    } else {
                        state.confirmationPIN = String(state.confirmationPIN.dropLast())
                    }
                }
                return .none

            case .biometricAuthenticationResponse(.success):
                return .none

            case .biometricAuthenticationResponse(.failure(let error)):
                state.isBiometricEnabled = false
                state.errorMessage = error.localizedDescription
                return .none

            case .saveButtonTapped:
                guard state.primaryPIN.count == 4 else {
                    state.errorMessage = "PIN must have exactly 4 digits."
                    return .none
                }

                guard state.primaryPIN == state.confirmationPIN else {
                    state.errorMessage = "PINs do not match."
                    state.confirmationPIN = ""
                    state.activeEntry = .confirmation
                    return .none
                }

                do {
                    try appLockClient.savePIN(state.primaryPIN)
                    appLockClient.setBiometricUnlockEnabled(
                        state.isBiometricAvailable && state.isBiometricEnabled
                    )
                    return .send(.delegate(.didSave))
                } catch {
                    state.errorMessage = error.localizedDescription
                    return .none
                }

            case .delegate:
                return .none
            }
        }
    }

    private func sanitizedPIN(_ value: String) -> String {
        String(value.filter(\.isNumber).prefix(4))
    }
}

extension AppLockSetupReducer.Action: Equatable {
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
        case (.cancelButtonTapped, .cancelButtonTapped):
            return true
        case (.deleteButtonTapped, .deleteButtonTapped):
            return true
        case (.delegate(let lhs), .delegate(let rhs)):
            return lhs == rhs
        case (.digitTapped(let lhs), .digitTapped(let rhs)):
            return lhs == rhs
        case (.entryTapped(let lhs), .entryTapped(let rhs)):
            return lhs == rhs
        case (.saveButtonTapped, .saveButtonTapped):
            return true
        default:
            return false
        }
    }
}
