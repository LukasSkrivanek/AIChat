//
//  CreateAccountReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 21.03.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CreateAccountReducer {

    enum Mode: String, CaseIterable, Equatable {
        case signIn = "Sign In"
        case createAccount = "Sign Up"
    }

    @Dependency(\.authManager) var authManager
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.userManager) var userManager

    @ObservableState
    struct State: Equatable {
        @Presents var alert: AlertState<AlertAction>?
        var confirmPassword = ""
        var email = ""
        var isLoading = false
        var mode: Mode = .createAccount
        var password = ""
        var validation = Validation()

        struct Validation: Equatable {
            var confirmPassword: String?
            var email: String?
            var password: String?

            var hasErrors: Bool {
                email != nil || password != nil || confirmPassword != nil
            }
        }

        var forgotPasswordVisible: Bool {
            mode == .signIn
        }

        var submitButtonTitle: String {
            switch mode {
            case .createAccount:
                "Create account"
            case .signIn:
                "Sign in"
            }
        }

        var subtitle: String {
            switch mode {
            case .createAccount:
                "Create your account with your email and password."
            case .signIn:
                "Stay connected by signing in with your email and password."
            }
        }

        var title: String {
            switch mode {
            case .createAccount:
                "Create your account"
            case .signIn:
                "Welcome Back"
            }
        }
    }

    enum Action: BindableAction {
        case alert(PresentationAction<AlertAction>)
        case authResponse(Result<(user: UserAuthInfo, isNewUser: Bool), any Error>)
        case binding(BindingAction<State>)
        case closeButtonTapped
        case delegate(DelegateAction)
        case forgotPasswordButtonTapped
        case forgotPasswordResponse(Result<Void, any Error>)
        case modeSelected(CreateAccountReducer.Mode)
        case submitButtonTapped
    }

    @CasePathable
    enum AlertAction: Equatable {
        case dismiss
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didSignIn(isNewUser: Bool, didCompleteOnboarding: Bool)
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.email):
                state.validation.email = validateEmail(state.email)
                return .none

            case .binding(\.password):
                state.validation.password = validatePassword(state.password)
                if state.mode == .createAccount {
                    state.validation.confirmPassword = validateConfirmPassword(
                        state.confirmPassword,
                        password: state.password
                    )
                }
                return .none

            case .binding(\.confirmPassword):
                state.validation.confirmPassword = validateConfirmPassword(
                    state.confirmPassword,
                    password: state.password
                )
                return .none

            case .binding:
                return .none

            case .closeButtonTapped:
                return .run { _ in
                    await dismiss()
                }

            case .modeSelected(let mode):
                state.alert = nil
                state.email = trimmed(state.email)
                state.confirmPassword = ""
                state.isLoading = false
                state.password = ""
                state.mode = mode
                state.validation = State.Validation(
                    confirmPassword: nil,
                    email: validateEmail(state.email),
                    password: nil
                )
                return .none

            case .submitButtonTapped:
                state.validation = State.Validation(
                    confirmPassword: state.mode == .createAccount
                    ? validateConfirmPassword(state.confirmPassword, password: state.password)
                    : nil,
                    email: validateEmail(state.email),
                    password: validatePassword(state.password)
                )

                guard !state.validation.hasErrors else {
                    return .none
                }

                state.isLoading = true
                return .run { [email = trimmed(state.email), password = state.password, mode = state.mode] send in
                    await send(
                        .authResponse(
                            Result {
                                switch mode {
                                case .createAccount:
                                    return try await authManager.createUser(
                                        email: email,
                                        password: password
                                    )
                                case .signIn:
                                    return try await authManager.signIn(
                                        email: email,
                                        password: password
                                    )
                                }
                            }
                        )
                    )
                }

            case .authResponse(.success(let result)):
                return .run { send in
                    do {
                        let currentUser = try await userManager.establishUserSession(
                            auth: result.user,
                            isNewUser: result.isNewUser
                        )
                        await send(
                            .delegate(
                                .didSignIn(
                                    isNewUser: result.isNewUser,
                                    didCompleteOnboarding: currentUser.didCompleteOnboarding == true
                                )
                            )
                        )
                    } catch {
                        await send(.authResponse(.failure(error)))
                    }
                }

            case .authResponse(.failure(let error)):
                state.isLoading = false
                state.alert = AlertState(
                    title: { TextState("Could not continue") },
                    actions: {
                        ButtonState(action: .dismiss) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .none

            case .forgotPasswordButtonTapped:
                let emailError = validateEmail(state.email)
                state.validation.email = emailError

                guard emailError == nil else {
                    return .none
                }

                state.isLoading = true
                return .run { [email = trimmed(state.email)] send in
                    await send(
                        .forgotPasswordResponse(
                            Result {
                                try await authManager.sendPasswordReset(email: email)
                            }
                        )
                    )
                }

            case .forgotPasswordResponse(.success):
                state.isLoading = false
                state.alert = AlertState(
                    title: { TextState("Reset email sent") },
                    actions: {
                        ButtonState(action: .dismiss) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState("Check your inbox for password reset instructions.")
                    }
                )
                return .none

            case .forgotPasswordResponse(.failure(let error)):
                state.isLoading = false
                state.alert = AlertState(
                    title: { TextState("Could not reset password") },
                    actions: {
                        ButtonState(action: .dismiss) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(errorMessage(for: error))
                    }
                )
                return .none

            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                return .none

            case .delegate:
                state.isLoading = false
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension CreateAccountReducer {
    private func errorMessage(for error: any Error) -> String {
        switch error {
        case let error as AuthServiceError:
            error.errorDescription ?? "Something went wrong."
        case let error as UserServiceError:
            error.errorDescription ?? "Something went wrong."
        default:
            error.localizedDescription
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validateConfirmPassword(
        _ confirmPassword: String,
        password: String
    ) -> String? {
        guard !confirmPassword.isEmpty else {
            return "Repeat your password."
        }

        guard confirmPassword == password else {
            return "Passwords do not match."
        }

        return nil
    }

    private func validateEmail(_ email: String) -> String? {
        let value = trimmed(email)

        guard !value.isEmpty else {
            return "Enter your email address."
        }

        guard value.contains("@"), value.contains(".") else {
            return AuthServiceError.invalidEmail.errorDescription
        }

        return nil
    }

    private func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else {
            return "Enter your password."
        }

        guard password.count >= 6 else {
            return AuthServiceError.weakPassword.errorDescription
        }

        return nil
    }
}
