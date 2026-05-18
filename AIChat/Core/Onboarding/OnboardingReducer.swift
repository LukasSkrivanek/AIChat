//
//  OnboardingReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 16.05.2026.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct OnboardingReducer {

    enum Step: Equatable {
        case colorSelection
        case completed
        case intro
    }

    enum ProfileColor: String, CaseIterable, Equatable, Hashable, Identifiable {
        case blue
        case cyan
        case green
        case indigo
        case mint
        case orange
        case purple
        case red
        case teal

        var id: Self { self }

        var color: Color {
            switch self {
            case .blue:
                return .blue
            case .cyan:
                return .cyan
            case .green:
                return .green
            case .indigo:
                return .indigo
            case .mint:
                return .mint
            case .orange:
                return .orange
            case .purple:
                return .purple
            case .red:
                return .red
            case .teal:
                return .teal
            }
        }
    }

    @Dependency(\.continuousClock)
    var clock
    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        var isCompletingProfileSetup = false
        var selectedColor: ProfileColor?
        var step: Step = .intro
        @Presents var alert: AlertState<Action.Alert>?

        let profileColors: [ProfileColor]

        init(
            isCompletingProfileSetup: Bool = false,
            profileColors: [ProfileColor] = ProfileColor.allCases,
            selectedColor: ProfileColor? = nil,
            step: Step = .intro,
            alert: AlertState<Action.Alert>? = nil
        ) {
            self.isCompletingProfileSetup = isCompletingProfileSetup
            self.profileColors = profileColors
            self.selectedColor = selectedColor
            self.step = step
            self.alert = alert
        }
    }

    enum Action {
        case continueFromColorButtonTapped
        case delegate(Delegate)
        case finishButtonTapped
        case finishProfileSetupCompleted
        case finishProfileSetupFailed(String)
        case getStartedButtonTapped
        case profileColorTapped(ProfileColor)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert: Equatable {
            case dismiss
        }

        @CasePathable
        enum Delegate: Equatable {
            case didFinish
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .continueFromColorButtonTapped:
                guard state.selectedColor != nil else {
                    return .none
                }
                state.step = .completed
                return .none

            case .finishButtonTapped:
                guard let selectedColor = state.selectedColor else {
                    return .none
                }
                state.isCompletingProfileSetup = true
                return .run { send in
                    do {
                        try await userManager.makeOnboardingCompletedCurrentUser(
                            profileColorHex: selectedColor.color.asHex()
                        )
                        await send(.finishProfileSetupCompleted)
                    } catch {
                        await send(.finishProfileSetupFailed(errorMessage(for: error)))
                    }
                }

            case .finishProfileSetupCompleted:
                state.isCompletingProfileSetup = false
                return .send(.delegate(.didFinish))

            case .finishProfileSetupFailed(let message):
                state.isCompletingProfileSetup = false
                state.alert = AlertState(
                    title: { TextState("Could not complete setup") },
                    actions: {
                        ButtonState(action: .dismiss) {
                            TextState("OK")
                        }
                    },
                    message: {
                        TextState(message)
                    }
                )
                return .none

            case .getStartedButtonTapped:
                state.step = .colorSelection
                return .none

            case .profileColorTapped(let color):
                state.selectedColor = color
                return .none

            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

extension OnboardingReducer {
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
}
