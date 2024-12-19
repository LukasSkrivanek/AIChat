//
//  WelcomeView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct WelcomeView: View {
    @State private var imageName: String = Constants.randomImage
    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                titleSection
                    .padding(.top, 25)
                NavigationLink {
                    OnboardingCompletedView()
                } label: {
                    Text("Get Started")
                        .callToActionButton()
                }
                .padding(16)
                ctaButtons
                    .padding(.bottom, 8)
                policySection
                    .foregroundStyle(.accent)
            }
        }
    }
    
    private var titleSection: some View {
        VStack {
            Text("AI Chat 👍")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Skrivanek Production")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtons: some View {
        VStack(alignment: .center, spacing: 2) {
            Text("Already have an account? Sign in")
                .underline()
                .padding(8)
                .tappableBackground()
                .onTapGesture {
                    // clickable
                }
            
        }
    }
    
    private var policySection: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Terms of Service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4, height: 4)
            Link(destination: URL(string: Constants.privacyPolicyUrl)!) {
                Text("Privacy Policy")
            }
            
        }
    }
}

#Preview {
    WelcomeView()
}
