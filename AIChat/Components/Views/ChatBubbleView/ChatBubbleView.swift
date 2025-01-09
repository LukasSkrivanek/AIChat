//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by macbook on 07.01.2025.
//

import SwiftUI

struct ChatBubbleView: View {
    var showImage: Bool = true
    var text: String = "Hello, World!"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var imageName: String?
    var onImagePress: (() -> Void)?
    
    let offset: CGFloat = 14
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                            .anyButton {
                                onImagePress?()
                            }
                    } else {
                        Rectangle()
                            .fill(.secondary)
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .offset(y: offset)
            }
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    VStack {
        ChatBubbleView()
        ChatBubbleView(text: "Lorem ipsum dolor sit amet consectetur adipiscing elite elite      elite              ")
        ChatBubbleView()
        ChatBubbleView(
            showImage: false,
            text: "hi",
            textColor: .white,
            backgroundColor: .accent 
        )
    }
}
