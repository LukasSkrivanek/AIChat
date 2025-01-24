//
//  CreateAccountView.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.authService) private var authService
    @Environment(\.dismiss) private var dismiss
    var title: String = "Create Account"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void )?
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
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
                onSignInApplePress()
            }
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
    }
    func onSignInApplePress() {
        Task {
            do {
                let result = try await authService.signInApple()
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                
            }
        }
    }
    
}

#Preview {
    CreateAccountView()
}
