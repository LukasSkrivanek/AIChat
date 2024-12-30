//
//  CategoryCellVIew.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//

import SwiftUI

struct CategoryCellView: View {
    var title: String = "Aliens"
    var imageName: String = Constants.randomImage
    var font: Font = .title2
    var cornerRadius: CGFloat = 15
    
    var body: some View {
        ZStack {
            // Background Image
            ImageLoaderView(urlString: Constants.randomImage)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .bottomLeading) {
                    Text(title)
                        .font(font)
                        .foregroundColor(.white)
                        .padding(16)
                        .addingGradientBackgroundForText()
                }
    
        }
        .cornerRadius(cornerRadius)
    }
}

#Preview {
    VStack {
        CategoryCellView()
            .frame(width: 150)
        
        CategoryCellView()
            .frame(width: 300)
        CategoryCellView(title: "")
        
    }
}
