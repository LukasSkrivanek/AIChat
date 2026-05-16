//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingColorView: View {
    let store: StoreOf<OnboardingReducer>

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if store.selectedColor != nil {
                    ctaButton
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        })
        .animation(.smooth, value: store.selectedColor)
    }

    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders]) {
                Section(header:
                            Text("Select a profile color")
                    .font(.headline)
                ) {
                    ForEach(store.profileColors) { loopedColor in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                loopedColor.color
                                    .clipShape(Circle())
                                    .padding(store.selectedColor == loopedColor ? 10 : 0)
                            }
                            .onTapGesture {
                                store.send(.profileColorTapped(loopedColor))
                            }
                    }
                }
            }
    }

    private var ctaButton: some View {
        Button {
            store.send(.continueFromColorButtonTapped)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
        .padding(24)
    }
}

#Preview {
    OnboardingColorView(
        store: Store(initialState: OnboardingReducer.State(selectedColor: .mint)) {
            OnboardingReducer()
        }
    )
}
