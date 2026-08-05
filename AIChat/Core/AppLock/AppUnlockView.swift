//
//  AppUnlockView.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import SwiftUI

struct AppUnlockView: View {

    @Bindable var store: StoreOf<AppUnlockReducer>

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 18),
        count: 3
    )

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            header()

            VStack(spacing: 14) {
                pinSlots()

                if let errorMessage = store.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                } else {
                    Text("4-digit PIN")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            keypad()

            Spacer(minLength: 12)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color.accent.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .task {
            store.send(.task)
        }
    }

    private func header() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.accent)

            Text("Unlock AIChat")
                .font(.title2.weight(.semibold))

            Text("Enter your PIN to continue.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func pinSlots() -> some View {
        HStack(spacing: 14) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 62, height: 68)
                    .overlay {
                        Group {
                            if store.pin.count > index {
                                Circle()
                                    .fill(Color.primary)
                                    .frame(width: 12, height: 12)
                            } else {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .strokeBorder(Color.secondary.opacity(0.22), lineWidth: 1)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
            }
        }
    }

    private func keypad() -> some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(1...9, id: \.self) { number in
                digitButton("\(number)")
            }

            biometricKey()
            digitButton("0")
            deleteKey()
        }
    }

    private func biometricKey() -> some View {
        Group {
            if store.isBiometricAvailable {
                Button {
                    store.send(.biometricButtonTapped)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: store.supportedBiometry == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 24, weight: .medium))
                        Text(store.supportedBiometry.displayName)
                            .font(.caption)
                    }
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
                .disabled(store.isAuthenticating)
            } else {
                Color.clear
                    .frame(height: 78)
            }
        }
    }

    private func deleteKey() -> some View {
        Button {
            guard !store.pin.isEmpty else {
                return
            }
            store.send(.binding(.set(\.pin, String(store.pin.dropLast()))))
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(
                    store.pin.isEmpty
                    ? Color.secondary.opacity(0.35)
                    : Color.primary
                )
                .frame(maxWidth: .infinity)
                .frame(height: 78)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
        .disabled(store.pin.isEmpty)
    }

    private func digitButton(_ digit: String) -> some View {
        Button {
            guard store.pin.count < 4 else {
                return
            }
            store.send(.binding(.set(\.pin, store.pin + digit)))
        } label: {
            Text(digit)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 78)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AppUnlockView(
        store: Store(
            initialState: AppUnlockReducer.State(
                isBiometricUnlockEnabled: true,
                supportedBiometry: .faceID
            )
        ) {
            AppUnlockReducer()
                .dependency(\.appLockClient, .previewValue)
                .dependency(\.biometricAuthClient, .previewValue)
        }
    )
}
