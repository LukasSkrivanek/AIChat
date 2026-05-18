//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import ComposableArchitecture
import SwiftUI

struct OnboardingCompletedView: View {
    let store: StoreOf<OnboardingReducer>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Complete !")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(store.selectedColor?.color ?? .accent)

            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            AsyncCallToActionButton(
                isLoading: store.isCompletingProfileSetup,
                title: "Finish") {
                    store.send(.finishButtonTapped)
                }
        })
        .padding(24)
    }
}

#Preview {
    NavigationStack {
        OnboardingCompletedView(
            store: OnboardingFlowPreview.store(
                selectedColor: .mint,
                step: .completed
            )
        )
    }
}
