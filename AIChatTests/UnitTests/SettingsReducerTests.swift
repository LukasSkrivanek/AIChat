//
//  SettingsReducerTests.swift
//  AIChatTests
//
//  Created by macbook on 13.07.2026.
//

import Foundation
import Testing
import ComposableArchitecture
@testable import AIChat

@Suite("SettingsReducer tests")
struct SettingsReducerTests {

    @Test
    func deleteAccountButtonTappedPresentsConfirmationAlert() async {
        let store = TestStore(
            initialState: SettingsReducer.State()
        ) {
            SettingsReducer()
        }

        await store.send(.deleteAccountButtonTapped) {
            $0.alert = AlertState {
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
        }
    }

    @Test
    func deleteAccountConfirmedSuccessSendsDelegate() async {
        let clock = TestClock()
        let currentUser = UserModel.mock

        let store = TestStore(
            initialState: SettingsReducer.State(
                alert: AlertState {
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
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.continuousClock = clock
            $0.authManager = AuthManager(service: MockAuthService())
            $0.userManager = UserManager(
                remoteService: MockUserService(user: currentUser),
                localService: MockFileManagerUserPersistence(user: currentUser)
            )
        }

        await store.send(.alert(.presented(.deleteAccountConfirmed))) {
            $0.alert = nil
            $0.isDeletingAccount = true
        }
        await store.receive(\.deleteAccountSucceeded) {
            $0.isDeletingAccount = false
        }
        await store.receive(\.delegate.didDeleteAccount)
    }

    @Test
    func deleteAccountConfirmedFailurePresentsErrorAlert() async {
        let clock = TestClock()
        let currentUser = UserModel.mock

        let store = TestStore(
            initialState: SettingsReducer.State(
                alert: AlertState {
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
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.continuousClock = clock
            $0.authManager = AuthManager(service: FailingAuthService())
            $0.userManager = UserManager(
                remoteService: MockUserService(user: currentUser),
                localService: MockFileManagerUserPersistence(user: currentUser)
            )
        }

        await store.send(.alert(.presented(.deleteAccountConfirmed))) {
            $0.alert = nil
            $0.isDeletingAccount = true
        }
        await store.receive(\.deleteAccountFailed, "You're offline. Please reconnect and try again.") {
            $0.isDeletingAccount = false
            $0.alert = AlertState(
                title: { TextState("Could not delete account") },
                actions: {
                    ButtonState(action: .errorDismissed) {
                        TextState("OK")
                    }
                },
                message: {
                    TextState("You're offline. Please reconnect and try again.")
                }
            )
        }
    }

    @Test
    func deleteAccountConfirmedTimeoutPresentsTimeoutAlert() async {
        let clock = TestClock()
        let currentUser = UserModel.mock

        let store = TestStore(
            initialState: SettingsReducer.State(
                alert: AlertState {
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
            )
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.continuousClock = clock
            $0.authManager = AuthManager(service: HangingAuthService())
            $0.userManager = UserManager(
                remoteService: MockUserService(user: currentUser),
                localService: MockFileManagerUserPersistence(user: currentUser)
            )
        }

        await store.send(.alert(.presented(.deleteAccountConfirmed))) {
            $0.alert = nil
            $0.isDeletingAccount = true
        }
        await clock.advance(by: .seconds(8))
        await store.receive(\.deleteAccountTimedOut) {
            $0.isDeletingAccount = false
            $0.alert = AlertState(
                title: { TextState("Could not delete account") },
                actions: {
                    ButtonState(action: .errorDismissed) {
                        TextState("OK")
                    }
                },
                message: {
                    TextState("You're offline or the request took too long. Please reconnect and try again.")
                }
            )
        }
    }

    @Test
    func signOutSucceededSendsDelegate() async {
        let store = TestStore(
            initialState: SettingsReducer.State()
        ) {
            SettingsReducer()
        }

        await store.send(.signOutSucceeded)
        await store.receive(\.delegate.didSignOut)
    }

    @Test
    func signOutButtonTappedFailurePresentsErrorAlert() async {
        let store = TestStore(
            initialState: SettingsReducer.State()
        ) {
            SettingsReducer()
        } withDependencies: {
            $0.authManager = AuthManager(service: FailingAuthService())
            $0.userManager = UserManager(
                remoteService: MockUserService(),
                localService: MockFileManagerUserPersistence()
            )
        }

        await store.send(.signOutButtonTapped)
        await store.receive(\.signOutFailed, "You're offline. Please reconnect and try again.") {
            $0.alert = AlertState(
                title: { TextState("Could not sign out") },
                actions: {
                    ButtonState(action: .errorDismissed) {
                        TextState("OK")
                    }
                },
                message: {
                    TextState("You're offline. Please reconnect and try again.")
                }
            )
        }
    }

    @Test
    func createAccountDidSignInSendsDidFinishCreateAccountDelegate() async {
        let store = TestStore(
            initialState: SettingsReducer.State(
                createAccount: CreateAccountReducer.State()
            )
        ) {
            SettingsReducer()
        }

        await store.send(
            .createAccount(
                .presented(
                    .delegate(
                        .didSignIn(
                            isNewUser: false,
                            didCompleteOnboarding: true
                        )
                    )
                )
            )
        )
        await store.receive(\.delegate.didFinishCreateAccount)
    }

    @Test
    func errorDismissedClearsAlert() async {
        let store = TestStore(
            initialState: SettingsReducer.State(
                alert: AlertState(
                    title: { TextState("Could not sign out") },
                    actions: {
                        ButtonState(action: .errorDismissed) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState("You're offline. Please reconnect and try again.")
                    }
                )
            )
        ) {
            SettingsReducer()
        }

        await store.send(.alert(.presented(.errorDismissed))) {
            $0.alert = nil
        }
    }
}

private struct FailingAuthService: AuthService {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        nil
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        throw AuthServiceError.network
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        throw AuthServiceError.network
    }

    func signOut() throws {
        throw AuthServiceError.network
    }

    func deleteAccount() async throws {
        throw AuthServiceError.network
    }
}

private struct HangingAuthService: AuthService {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        nil
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        throw CancellationError()
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        throw CancellationError()
    }

    func signOut() throws {
        throw CancellationError()
    }

    func deleteAccount() async throws {
        try await Task.never()
    }
}
