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
        NavigationStack(
            path: Binding(
                get: { store.path },
                set: { store.send(.pathChanged($0)) }
            )
        ) {
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
            .navigationDestination(for: OnboardingReducer.Path.self) { path in
                switch path {
                case .colorSelection:
                    OnboardingColorView(store: store)
                case .completed:
                    OnboardingCompletedView(store: store)
                }
            }
        }
    }
}

#Preview {
    OnboardingIntroView(
        store: Store(initialState: OnboardingReducer.State()) {
            OnboardingReducer()
        }
    )
}
