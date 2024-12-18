//
//  WelcomeView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .frame(maxHeight: .infinity)
                NavigationLink {
                    OnboardingCompletedView()
                } label: {
                    Text("Get Started")
                        .callToActionButton()
                }

            }
            .padding(16)
        }
    }
}

#Preview {
    WelcomeView()
}
