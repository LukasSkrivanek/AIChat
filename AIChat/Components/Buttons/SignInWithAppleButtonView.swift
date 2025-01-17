//
//  SignInWithAppleButtonView.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import AuthenticationServices
import SwiftUI

public struct SignInWithAppleButtonView: View {
    public let type: ASAuthorizationAppleIDButton.ButtonType
    public let style: ASAuthorizationAppleIDButton.Style
    public let cornerRadius: CGFloat
    
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType,
        style: ASAuthorizationAppleIDButton.Style,
        cornerRadius: CGFloat
    ) {
        self.type = type
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.001)
            SignInWithAppleButtonViewRepresentable(type: type, style: style, cornerRadius: cornerRadius)
                .disabled(true)
        }
    }
}

private struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    let cornerRadius: CGFloat
    
    func makeUIView(context: Context) -> some UIView {
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        button.cornerRadius = cornerRadius
        return button
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    } 
    
    func makeCoordinator() {
    }
}

#Preview {
    ZStack {
        SignInWithAppleButtonView(
            type: .continue,
            style: .black,
            cornerRadius: 10
        )
        .frame(height: 50)
        
    }
    .padding()
}
