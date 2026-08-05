//
//  CreateAccountView.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//

import ComposableArchitecture
import SwiftUI

struct CreateAccountView: View {

    @Bindable var store: StoreOf<CreateAccountReducer>
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case confirmPassword
        case email
        case password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header()
                    heroSection()
                        .padding(.top, 20)
                    modeSwitch()
                        .padding(.top, 28)
                    formCard()
                        .padding(.top, 24)
                    footerSection()
                        .padding(.top, 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(Color(uiColor: .systemBackground))
        }
        .interactiveDismissDisabled(store.isLoading)
        .alert($store.scope(state: \.alert, action: \.alert))
        .onDisappear {
            focusedField = nil
        }
    }

    private func header() -> some View {
        HStack {
            Button {
                store.send(.closeButtonTapped)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func heroSection() -> some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.black)
                .frame(width: 74, height: 74)
                .overlay {
                    Image(systemName: store.mode == .signIn ? "person.fill" : "person.badge.plus.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                }

            Text(store.title)
                .font(.system(size: 31, weight: .semibold))
                .multilineTextAlignment(.center)

            Text(store.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 290)
        }
        .frame(maxWidth: .infinity)
    }

    private func modeSwitch() -> some View {
        HStack(spacing: 8) {
            modeButton(.signIn)
            modeButton(.createAccount)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .animation(.easeInOut(duration: 0.18), value: store.mode)
    }

    private func modeButton(_ mode: CreateAccountReducer.Mode) -> some View {
        Button {
            focusedField = nil
            store.send(.modeSelected(mode))
        } label: {
            Text(mode.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(store.mode == mode ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(store.mode == mode ? Color.black : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    private func formCard() -> some View {
        VStack(spacing: 18) {
            inputSection(
                title: "Email Address",
                error: store.validation.email
            ) {
                TextField("hello@example.com", text: $store.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                    .authField()
            }

            inputSection(
                title: "Password",
                error: store.validation.password
            ) {
                SecureField("Enter password", text: $store.password)
                    .textContentType(store.mode == .createAccount ? .newPassword : .password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(store.mode == .createAccount ? .next : .go)
                    .onSubmit {
                        if store.mode == .createAccount {
                            focusedField = .confirmPassword
                        } else {
                            focusedField = nil
                            store.send(.submitButtonTapped)
                        }
                    }
                    .authField()
            }

            if store.mode == .createAccount {
                inputSection(
                    title: "Confirm Password",
                    error: store.validation.confirmPassword
                ) {
                    SecureField("Repeat password", text: $store.confirmPassword)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.go)
                        .onSubmit {
                            focusedField = nil
                            store.send(.submitButtonTapped)
                        }
                        .authField()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if store.forgotPasswordVisible {
                HStack {
                    Spacer()
                    Button("Forgot password?") {
                        store.send(.forgotPasswordButtonTapped)
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                }
            }

            submitButton()
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.12), lineWidth: 1)
        }
        .animation(.easeInOut(duration: 0.18), value: store.mode)
    }

    private func inputSection<Content: View>(
        title: String,
        error: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            content()

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    private func submitButton() -> some View {
        Button {
            focusedField = nil
            store.send(.submitButtonTapped)
        } label: {
            HStack(spacing: 10) {
                if store.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                Text(store.submitButtonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .foregroundStyle(.white)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(store.isLoading || store.validation.hasErrors)
        .opacity(store.isLoading || store.validation.hasErrors ? 0.7 : 1)
    }

    private func footerSection() -> some View {
        VStack(spacing: 8) {
            Text(
                store.mode == .createAccount
                ? "Already have an account?"
                : "Don't have an account yet?"
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Button(
                store.mode == .createAccount
                ? "Sign In"
                : "Sign Up"
            ) {
                focusedField = nil
                store.send(.modeSelected(
                    store.mode == .createAccount ? .signIn : .createAccount
                ))
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.primary)
        }
        .padding(.bottom, 12)
    }
}

private extension View {
    func authField() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
}

#Preview("Create account") {
    CreateAccountView(
        store: Store(
            initialState: CreateAccountReducer.State(
                mode: .createAccount
            )
        ) {
            CreateAccountReducer()
        }
    )
}

#Preview("Sign in") {
    CreateAccountView(
        store: Store(
            initialState: CreateAccountReducer.State(
                mode: .signIn
            )
        ) {
            CreateAccountReducer()
        }
    )
}
