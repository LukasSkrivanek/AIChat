//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingIntroView: View {

    let store: StoreOf<OnboardingReducer>

    var body: some View {
        ZStack {
            switch store.step {
            case .intro:
                introStep
                    .transition(stepTransition())

            case .colorSelection:
                OnboardingColorView(store: store)
                    .transition(stepTransition())

            case .completed:
                OnboardingCompletedView(store: store)
                    .transition(
                        stepTransition(
                            removal: .scale(scale: 0.96).combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.smooth(duration: 0.35), value: store.step)
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }

    private var introStep: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat\n with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses ")
            }
            .baselineOffset(6)
            .frame(maxHeight: .infinity)
            .padding(24)

            Button {
                store.send(.getStartedButtonTapped)
            } label: {
                Text("Continue")
                    .callToActionButton()
            }
            .padding(24)
            .font(.title3)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func stepTransition(
        removal: AnyTransition = .move(edge: .leading).combined(with: .opacity)
    ) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: removal
        )
    }
}

#Preview {
    OnboardingFlowPreviewView(store: OnboardingFlowPreview.store())
}
