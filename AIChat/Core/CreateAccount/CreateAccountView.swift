//
//  CreateAccountView.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//

import SwiftUI
import ComposableArchitecture

struct CreateAccountView: View {

    @Bindable var store: StoreOf<CreateAccountReducer>

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(store.subtitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 55)
            .anyButton(.press) {
                store.send(.signInAppleButtonTapped)
            }
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}

#Preview {
    CreateAccountView(
        store: Store(initialState: CreateAccountReducer.State()) {
            CreateAccountReducer()
        }
    )
}
