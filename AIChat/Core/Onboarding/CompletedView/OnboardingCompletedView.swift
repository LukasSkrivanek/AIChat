//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var rootState
    var body: some View {
            VStack {
                Text("Onboarding Completed")
                    .frame(maxHeight: .infinity)
                Button {
                    // finish onboarding and enter app!
                    onFinishButtonPressed()
                } label: {
                    Text("Finish")
                        .callToActionButton()
                }

            }
            .padding(16)
        }
    func onFinishButtonPressed() {
        rootState.updateViewState(showTabBarView: true)
    }
    }
#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
