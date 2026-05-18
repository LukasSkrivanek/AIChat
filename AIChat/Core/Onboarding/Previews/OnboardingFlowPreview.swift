//
//  OnboardingFlowPreview.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 17.05.2026.
//

import ComposableArchitecture
import SwiftUI

enum OnboardingFlowPreview {
    static func store(
        isCompletingProfileSetup: Bool = false,
        selectedColor: OnboardingReducer.ProfileColor? = nil,
        step: OnboardingReducer.Step = .intro
    ) -> StoreOf<OnboardingReducer> {
        Store(
            initialState: OnboardingReducer.State(
                isCompletingProfileSetup: isCompletingProfileSetup,
                selectedColor: selectedColor,
                step: step
            )
        ) {
            OnboardingReducer()
        }
    }
}

struct OnboardingFlowPreviewView: View {
    let store: StoreOf<OnboardingReducer>

    var body: some View {
        NavigationStack {
            OnboardingIntroView(store: store)
        }
    }
}

#Preview("Intro") {
    OnboardingFlowPreviewView(store: OnboardingFlowPreview.store())
}

#Preview("Color selection") {
    OnboardingFlowPreviewView(
        store: OnboardingFlowPreview.store(
            selectedColor: .mint,
            step: .colorSelection
        )
    )
}

#Preview("Completed") {
    OnboardingFlowPreviewView(
        store: OnboardingFlowPreview.store(
            selectedColor: .mint,
            step: .completed
        )
    )
}

#Preview("Completing profile") {
    OnboardingFlowPreviewView(
        store: OnboardingFlowPreview.store(
            isCompletingProfileSetup: true,
            selectedColor: .mint,
            step: .completed
        )
    )
}
