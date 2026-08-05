//
//  SettingsReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SettingsReducer {

    nonisolated private enum CancelID: Hashable, Sendable {
        case enableBiometricAfterSetup
        case deleteAccount
        case deleteAccountTimeout
        case pinChangeSecurityEmail
    }

    @Dependency(\.continuousClock)
    var clock
    @Dependency(\.appLockClient)
    var appLockClient
    @Dependency(\.authManager)
    var authManager
    @Dependency(\.biometricAuthClient)
    var biometricAuthClient
    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        @Presents
        var appLockSetup: AppLockSetupReducer.State?
        var isDeletingAccount = false
        var isAppLockEnabled = false
        var isBiometricUnlockEnabled = false
        var isPremium: Bool = true
        var isSendingSecurityEmail = false
        var isAnonymousUser: Bool = false
        var supportedBiometry: BiometricAuthClient.BiometryType = .none

        @Presents
        var createAccount: CreateAccountReducer.State?
        @Presents
        var alert: AlertState<AlertAction>?

        init(
            appLockSetup: AppLockSetupReducer.State? = nil,
            isDeletingAccount: Bool = false,
            isAppLockEnabled: Bool = false,
            isBiometricUnlockEnabled: Bool = false,
            isPremium: Bool = true,
            isSendingSecurityEmail: Bool = false,
            isAnonymousUser: Bool = false,
            supportedBiometry: BiometricAuthClient.BiometryType = .none,
            createAccount: CreateAccountReducer.State? = nil,
            alert: AlertState<AlertAction>? = nil
        ) {
            self.appLockSetup = appLockSetup
            self.isDeletingAccount = isDeletingAccount
            self.isAppLockEnabled = isAppLockEnabled
            self.isBiometricUnlockEnabled = isBiometricUnlockEnabled
            self.isPremium = isPremium
            self.isSendingSecurityEmail = isSendingSecurityEmail
            self.isAnonymousUser = isAnonymousUser
            self.supportedBiometry = supportedBiometry
            self.createAccount = createAccount
            self.alert = alert
        }
    }

    enum Action {
        case appLockButtonTapped
        case appLockSetup(PresentationAction<AppLockSetupReducer.Action>)
        case biometricUnlockToggled(Bool)
        case biometricUnlockToggleResponse(Result<Bool, any Error>)
        case biometricEnableAfterSetupResponse(Result<Void, any Error>)
        case changePinSecurityEmailResponse(Result<String, any Error>)
        case createAccountButtonTapped
        case deleteAccountSucceeded
        case deleteAccountFailed(String)
        case deleteAccountButtonTapped
        case deleteAccountTimedOut
        case delegate(DelegateAction)
        case disableAppLockButtonTapped
        case createAccount(PresentationAction<CreateAccountReducer.Action>)
        case signOutButtonTapped
        case signOutSucceeded
        case signOutFailed(String)
        case task
        case alert(PresentationAction<AlertAction>)
    }

    @CasePathable
    enum AlertAction: Equatable {
        case continueToPinChange
        case deleteAccountConfirmed
        case enableBiometricAfterSetup
        case errorDismissed
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didFinishCreateAccount
        case didDeleteAccount
        case didSignOut
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.supportedBiometry = biometricAuthClient.biometryType()
                state.isAppLockEnabled = appLockClient.isEnabled()
                state.isBiometricUnlockEnabled = appLockClient.isBiometricUnlockEnabled()
                state.isAnonymousUser = userManager.currentUser?.isAnonymous == true
                return .none

            case .appLockButtonTapped:
                let supportedBiometry = biometricAuthClient.biometryType()
                state.supportedBiometry = supportedBiometry
                state.isBiometricUnlockEnabled = appLockClient.isBiometricUnlockEnabled()

                guard state.isAppLockEnabled else {
                    presentAppLockSetup(
                        in: &state,
                        supportedBiometry: supportedBiometry,
                        mode: .setup
                    )
                    return .none
                }

                guard let email = userManager.currentUser?.email, !email.isEmpty else {
                    state.alert = AlertState(
                        title: { TextState("Email required") },
                        actions: {
                            ButtonState(action: .errorDismissed) {
                                TextState("OK")
                            }
                        },
                        message: {
                            TextState("Add an email-backed account before changing your PIN.")
                        }
                    )
                    return .none
                }

                state.isSendingSecurityEmail = true
                return .run { [email] send in
                    await send(
                        .changePinSecurityEmailResponse(
                            Result {
                                try await authManager.sendPasswordReset(email: email)
                                return email
                            }
                        )
                    )
                }
                .cancellable(id: CancelID.pinChangeSecurityEmail)

            case .biometricUnlockToggled(let isEnabled):
                return handleBiometricUnlockToggle(&state, isEnabled: isEnabled)

            case .changePinSecurityEmailResponse(.success(let email)):
                state.isSendingSecurityEmail = false
                state.alert = AlertState(
                    title: { TextState("Check your email") },
                    actions: {
                        ButtonState(action: .continueToPinChange) {
                            TextState("Continue")
                        }
                        ButtonState(role: .cancel) {
                            TextState("Later")
                        }
                    },
                    message: {
                        TextState(
                            "We sent a security email to \(email). After you review it, continue to change your PIN."
                        )
                    }
                )
                return .none

            case .changePinSecurityEmailResponse(.failure(let error)):
                state.isSendingSecurityEmail = false
                state.alert = AlertState(
                    title: { TextState("Could not continue") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .none

            case .createAccountButtonTapped:
                state.createAccount = CreateAccountReducer.State()
                return .none

            case .signOutButtonTapped:
                return .run { @MainActor send in
                    do {
                        try authManager.signOut()
                        userManager.signOut()
                        send(.signOutSucceeded)
                    } catch {
                        send(.signOutFailed(errorMessage(for: error)))
                    }
                }

            case .signOutSucceeded:
                return .send(.delegate(.didSignOut))

            case .signOutFailed(let message):
                state.alert = AlertState(
                    title: { TextState("Could not sign out") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
                    }
                )
                return .none

            case .deleteAccountButtonTapped:
                state.alert = AlertState {
                    TextState("Delete account?")
                } actions: {
                    ButtonState(role: .destructive, action: .deleteAccountConfirmed) {
                        TextState("Delete")
                    }
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("This action is permanent and cannot be undone. Your data will be deleted from our server.")
                }
                return .none

            case .disableAppLockButtonTapped:
                do {
                    try appLockClient.disable()
                    state.isAppLockEnabled = false
                    state.isBiometricUnlockEnabled = false
                } catch {
                    state.alert = AlertState(
                        title: { TextState("Could not update app lock") },
                        actions: {
                            ButtonState(action: .errorDismissed) {
                                TextState("OK")
                            }
                        },
                        message: {
                            TextState(error.localizedDescription)
                        }
                    )
                }
                return .none

            case .alert(.presented(.deleteAccountConfirmed)):
                state.alert = nil
                state.isDeletingAccount = true
                return .merge(
                    .run { @MainActor send in
                        do {
                            try await userManager.deleteCurrentUser()
                            try await authManager.deleteAccount()
                            send(.deleteAccountSucceeded)
                        } catch {
                            send(.deleteAccountFailed(errorMessage(for: error)))
                        }
                    }
                    .cancellable(id: CancelID.deleteAccount),

                    .run { send in
                        try await clock.sleep(for: .seconds(8))
                        await send(.deleteAccountTimedOut)
                    }
                    .cancellable(id: CancelID.deleteAccountTimeout)
                )

            case .alert(.presented(.enableBiometricAfterSetup)):
                state.alert = nil
                return .run { send in
                    await send(
                        .biometricEnableAfterSetupResponse(
                            Result {
                                try await biometricAuthClient.authenticate(
                                    "Enable biometric unlock for AIChat"
                                )
                            }
                        )
                    )
                }
                .cancellable(id: CancelID.enableBiometricAfterSetup)

            case .alert(.presented(.continueToPinChange)):
                state.alert = nil
                presentAppLockSetup(
                    in: &state,
                    supportedBiometry: state.supportedBiometry,
                    mode: .changePIN
                )
                return .none

            case .deleteAccountSucceeded:
                state.isDeletingAccount = false
                return .merge(
                    .cancel(id: CancelID.enableBiometricAfterSetup),
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout),
                    .send(.delegate(.didDeleteAccount))
                )

            case .deleteAccountFailed(let message):
                state.isDeletingAccount = false
                state.alert = AlertState(
                    title: { TextState("Could not delete account") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
                    }
                )
                return .merge(
                    .cancel(id: CancelID.enableBiometricAfterSetup),
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout)
                )

            case .deleteAccountTimedOut:
                state.isDeletingAccount = false
                state.alert = AlertState(
                    title: { TextState("Could not delete account") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: SettingsError.deleteTimedOut))
                    }
                )
                return .merge(
                    .cancel(id: CancelID.enableBiometricAfterSetup),
                    .cancel(id: CancelID.deleteAccount),
                    .cancel(id: CancelID.deleteAccountTimeout)
                )

            case .biometricEnableAfterSetupResponse(.success):
                state.isBiometricUnlockEnabled = true
                appLockClient.setBiometricUnlockEnabled(true)
                return .none

            case .biometricEnableAfterSetupResponse(.failure(let error)):
                state.alert = AlertState(
                    title: { TextState("Could not enable Face ID") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .none

            case .biometricUnlockToggleResponse(.success(let isEnabled)):
                state.isBiometricUnlockEnabled = isEnabled
                appLockClient.setBiometricUnlockEnabled(isEnabled)
                return .none

            case .biometricUnlockToggleResponse(.failure(let error)):
                state.isBiometricUnlockEnabled = false
                state.alert = AlertState(
                    title: { TextState("Could not enable biometrics") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .none

            case .alert(.presented(.errorDismissed)):
                state.alert = nil
                return .none

            case .appLockSetup(.presented(.delegate(.didCancel))):
                state.appLockSetup = nil
                return .none

            case .appLockSetup(.presented(.delegate(.didSave))):
                let wasAppLockEnabled = state.isAppLockEnabled
                state.appLockSetup = nil
                state.isAppLockEnabled = appLockClient.isEnabled()
                state.isBiometricUnlockEnabled = appLockClient.isBiometricUnlockEnabled()

                if !wasAppLockEnabled, state.supportedBiometry != .none {
                    let biometryDisplayName = state.supportedBiometry.displayName
                    state.alert = AlertState(
                        title: { TextState("Enable \(biometryDisplayName)?") },
                        actions: {
                            ButtonState(action: .enableBiometricAfterSetup) {
                                TextState("Enable")
                            }
                            ButtonState(role: .cancel) {
                                TextState("Not now")
                            }
                        },
                        message: {
                            TextState("You can use \(biometryDisplayName) after your PIN has been set up.")
                        }
                    )
                }
                return .none

            case .createAccount(.presented(.delegate(.didSignIn))):
                state.isAnonymousUser = false
                state.createAccount = nil

                guard !appLockClient.hasPIN() else {
                    return .send(.delegate(.didFinishCreateAccount))
                }

                let supportedBiometry = biometricAuthClient.biometryType()
                state.supportedBiometry = supportedBiometry
                state.isBiometricUnlockEnabled = appLockClient.isBiometricUnlockEnabled()
                presentAppLockSetup(
                    in: &state,
                    supportedBiometry: supportedBiometry,
                    mode: .setup
                )
                return .send(.delegate(.didFinishCreateAccount))

            case .appLockSetup(.dismiss):
                return .none

            case .createAccount(.dismiss):
                return .none

            case .alert(.dismiss):
                return .none

            case .appLockSetup, .createAccount:
                return .none

            case .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$appLockSetup, action: \.appLockSetup) {
            AppLockSetupReducer()
        }
        .ifLet(\.$createAccount, action: \.createAccount) {
            CreateAccountReducer()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension SettingsReducer {
    private enum SettingsError: LocalizedError {
        case deleteTimedOut

        var errorDescription: String? {
            switch self {
            case .deleteTimedOut:
                "You're offline or the request took too long. Please reconnect and try again."
            }
        }
    }

    private func errorMessage(for error: any Error) -> String {
        switch error {
        case let error as SettingsError:
            error.errorDescription ?? "Something went wrong."
        case let error as AuthServiceError:
            error.errorDescription ?? "Something went wrong."
        case let error as UserServiceError:
            error.errorDescription ?? "Something went wrong."
        default:
            error.localizedDescription
        }
    }

    private func handleBiometricUnlockToggle(
        _ state: inout State,
        isEnabled: Bool
    ) -> Effect<Action> {
        guard isEnabled else {
            state.isBiometricUnlockEnabled = false
            appLockClient.setBiometricUnlockEnabled(false)
            return .none
        }

        guard state.supportedBiometry != .none else {
            state.isBiometricUnlockEnabled = false
            presentBiometricsUnavailableAlert(in: &state)
            return .none
        }

        state.isBiometricUnlockEnabled = false
        return authenticateBiometricUnlockToggle()
    }

    private func authenticateBiometricUnlockToggle() -> Effect<Action> {
        let biometryDisplayName = biometricAuthClient.biometryType().displayName

        return .run { send in
            await send(
                .biometricUnlockToggleResponse(
                    Result {
                        try await biometricAuthClient.authenticate(
                            "Enable \(biometryDisplayName) for AIChat"
                        )
                        return true
                    }
                )
            )
        }
    }

    private func presentBiometricsUnavailableAlert(
        in state: inout State
    ) {
        state.alert = AlertState(
            title: { TextState("Biometrics unavailable") },
            actions: {
                ButtonState(action: .errorDismissed) {
                    TextState("OK")
                }
            },
            message: {
                TextState("Face ID or Touch ID is not available on this device.")
            }
        )
    }

    private func presentAppLockSetup(
        in state: inout State,
        supportedBiometry: BiometricAuthClient.BiometryType,
        mode: AppLockSetupReducer.State.Mode
    ) {
        state.appLockSetup = AppLockSetupReducer.State(
            isBiometricAvailable: supportedBiometry != .none,
            isBiometricEnabled: state.isBiometricUnlockEnabled,
            mode: mode
        )
    }
}
