//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var rootState
    @State private var isCompletingProfileSetup: Bool = false
    var selectedColor: Color = .accent
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Complete !")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)
            
            Text("We've set up your profile and you're ready to start chatting.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, content: {
            ctaButton
              
        })
       
        .padding(24)
    }
    private var ctaButton: some View {
        ZStack {
            if isCompletingProfileSetup {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Finish")
            }
            
        }
        .callToActionButton()
        .anyButton(.press, action: {
            onFinishButtonPressed()
        })
        .disabled(isCompletingProfileSetup == true)
        
    }
      
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        
        Task {
            try await Task.sleep(for: .seconds(3))
            // try await saveUserProfile(color: selectedColor)
            isCompletingProfileSetup = false
            rootState.updateViewState(showTabBarView: true)
        }
      
        
    }
}
#Preview {
    NavigationStack {
        OnboardingCompletedView(selectedColor: .mint)
            .environment(AppState())
    }
}
