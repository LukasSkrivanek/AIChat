//
//  WelcomeView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct WelcomeView: View {

    @Bindable var store: StoreOf<WelcomeReducer>

    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: Constants.randomImage)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                titleSection
                    .padding(.top, 25)
                Button {
                    store.send(.getStartedButtonTapped)
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
        .sheet(item: $store.scope(state: \.createAccount, action: \.createAccount)) { createAccountStore in
            CreateAccountView(store: createAccountStore)
                .presentationDetents([.medium])
        }
    }

    private var titleSection: some View {
        VStack {
            Text("AI Chat 👍")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Sky Lark Apps")
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
                    store.send(.signInButtonTapped)
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
    WelcomeView(
        store: Store(initialState: WelcomeReducer.State()) {
            WelcomeReducer()
        }
    )
}
