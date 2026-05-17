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
        Group {
            switch store.step {
            case .intro:
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

            case .colorSelection:
                OnboardingColorView(store: store)

            case .completed:
                OnboardingCompletedView(store: store)
            }
        }
    }
}

#Preview {
    OnboardingFlowPreviewView(store: OnboardingFlowPreview.store())
}
