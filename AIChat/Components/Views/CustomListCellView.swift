//
//  CustomListCellView.swift
//  AIChat
//
//  Created by macbook on 23.12.2024.
//
import SwiftUI

struct CustomListCellView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "An alien that is smilling in the park"
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                if let imageName = imageName {
                    ImageLoaderView(urlString: imageName)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 60)
                        .cornerRadius(16)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                if let title = title {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        CustomListCellView()
    }
}
