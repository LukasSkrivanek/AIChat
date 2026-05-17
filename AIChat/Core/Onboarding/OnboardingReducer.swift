//
//  OnboardingReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 16.05.2026.
//

import ComposableArchitecture
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

    @Dependency(\.continuousClock) var clock

    @ObservableState
    struct State: Equatable {
        var isCompletingProfileSetup = false
        var selectedColor: ProfileColor?
        var step: Step = .intro

        let profileColors: [ProfileColor]

        init(
            isCompletingProfileSetup: Bool = false,
            profileColors: [ProfileColor] = ProfileColor.allCases,
            selectedColor: ProfileColor? = nil,
            step: Step = .intro
        ) {
            self.isCompletingProfileSetup = isCompletingProfileSetup
            self.profileColors = profileColors
            self.selectedColor = selectedColor
            self.step = step
        }
    }

    enum Action {
        case continueFromColorButtonTapped
        case delegate(Delegate)
        case finishButtonTapped
        case finishProfileSetupCompleted
        case getStartedButtonTapped
        case profileColorTapped(ProfileColor)

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
                state.isCompletingProfileSetup = true
                return .run { send in
                    try await clock.sleep(for: .seconds(3))
                    await send(.finishProfileSetupCompleted)
                }

            case .finishProfileSetupCompleted:
                state.isCompletingProfileSetup = false
                return .send(.delegate(.didFinish))

            case .getStartedButtonTapped:
                state.step = .colorSelection
                return .none

            case .profileColorTapped(let color):
                state.selectedColor = color
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
