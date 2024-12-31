//
//  ChatRowCellView.swift
//  AIChat
//
//  Created by macbook on 31.12.2024.
//

import SwiftUI

struct ChatRowCellView: View {
    var imageName: String? = Constants.randomImage
    var headline: String? = "Alpha"
    var subheadline: String? = "This is the last message in the chat."
    var hasNewChat: Bool = true
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName {
                    ImageLoaderView(urlString: imageName)
                } else {
                    Rectangle()
                        .fill(.secondary.opacity(0.5))
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                if let headline {
                    Text(headline)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                if let subheadline {
                    Text(subheadline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if hasNewChat {
                Text("New")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .background(.blue)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(uiColor: UIColor.systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        List {
            ChatRowCellView()
                .removeRowFormatting()
                
            ChatRowCellView(hasNewChat: false)
                .removeRowFormatting()
                
            ChatRowCellView(imageName: nil)
                .removeRowFormatting()
            ChatRowCellView(headline: nil)
                .removeRowFormatting()
            ChatRowCellView(subheadline: nil)
                .removeRowFormatting()
        }
    }
}
