//
//  AppLockSetupView.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 18.07.2026.
//

import ComposableArchitecture
import SwiftUI

struct AppLockSetupView: View {

    @Bindable var store: StoreOf<AppLockSetupReducer>

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 18),
        count: 3
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header()

                    if store.shouldShowBiometricToggle {
                        biometricToggleCard()
                    }

                    activePinSection()

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    keypad()

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        Color.accent.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(store.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        store.send(.cancelButtonTapped)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        store.send(.saveButtonTapped)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func header() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "lock.shield")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.accent)

            Text(store.headerTitle)
                .font(.title3.weight(.semibold))

            Text(store.headerMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func pinSection(
        title: String,
        pin: String,
        entry: AppLockSetupReducer.PINEntry
    ) -> some View {
        let isActive = store.activeEntry == entry

        return Button {
            store.send(.entryTapped(entry))
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isActive ? .primary : .secondary)

                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(width: 54, height: 60)
                            .overlay {
                                Group {
                                    if pin.count > index {
                                        Circle()
                                            .fill(Color.primary)
                                            .frame(width: 11, height: 11)
                                    } else {
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .strokeBorder(
                                                (isActive ? Color.accent : Color.secondary)
                                                    .opacity(isActive ? 0.5 : 0.22),
                                                lineWidth: 1
                                            )
                                            .frame(width: 18, height: 18)
                                    }
                                }
                            }
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        isActive ? Color.accent.opacity(0.45) : Color.secondary.opacity(0.12),
                        lineWidth: isActive ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }

    private func activePinSection() -> some View {
        VStack(spacing: 12) {
            pinSection(
                title: store.activeEntry == .primary ? store.primaryTitle : store.confirmationTitle,
                pin: store.activeEntry == .primary ? store.primaryPIN : store.confirmationPIN,
                entry: store.activeEntry
            )

            HStack(spacing: 8) {
                stepIndicator(
                    title: "Enter PIN",
                    isComplete: store.primaryPIN.count == 4,
                    isActive: store.activeEntry == .primary
                )

                stepIndicator(
                    title: "Confirm PIN",
                    isComplete: store.confirmationPIN.count == 4,
                    isActive: store.activeEntry == .confirmation
                )
            }
        }
    }

    private func stepIndicator(
        title: String,
        isComplete: Bool,
        isActive: Bool
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(
                    isComplete
                    ? Color.green
                    : (isActive ? Color.accent : Color.secondary.opacity(0.45))
                )

            Text(title)
                .font(.caption.weight(isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    private func biometricToggleCard() -> some View {
        HStack(spacing: 14) {
            Image(systemName: "faceid")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.accent)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text(store.biometricToggleTitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Text("You can still fall back to your PIN anytime.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle(
                "",
                isOn: $store.isBiometricEnabled
            )
            .labelsHidden()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.12), lineWidth: 1)
        }
    }

    private func keypad() -> some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(1...9, id: \.self) { number in
                digitButton("\(number)")
            }

            Color.clear
                .frame(height: 78)

            digitButton("0")
            deleteButton()
        }
    }

    private func digitButton(_ digit: String) -> some View {
        Button {
            store.send(.digitTapped(digit))
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

    private func deleteButton() -> some View {
        Button {
            store.send(.deleteButtonTapped)
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(deleteButtonColor())
                .frame(maxWidth: .infinity)
                .frame(height: 78)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
        }
        .buttonStyle(.plain)
        .disabled(store.primaryPIN.isEmpty && store.confirmationPIN.isEmpty)
    }

    private func deleteButtonColor() -> Color {
        if store.primaryPIN.isEmpty && store.confirmationPIN.isEmpty {
            return Color.secondary.opacity(0.35)
        }
        return .primary
    }
}

#Preview {
    AppLockSetupView(
        store: Store(
            initialState: AppLockSetupReducer.State(
                isBiometricAvailable: true,
                isBiometricEnabled: true,
                mode: .changePIN
            )
        ) {
            AppLockSetupReducer()
                .dependency(\.appLockClient, .previewValue)
        }
    )
}
