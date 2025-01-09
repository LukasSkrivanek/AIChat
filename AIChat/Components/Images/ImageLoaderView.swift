//
//  ImageLoaderView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoaderView: View {
    var urlString: String = Constants.randomImage
    var resizingMode: ContentMode = .fill
    var forceTransitionAnimation: Bool = false
    
    var body: some View {
        Rectangle()
            .opacity(0.001)
            .overlay(
                WebImage(url: URL(string: urlString))
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
            )
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content
                    .drawingGroup()
            }
            .clipped()
        
    }
}



#Preview {
    ImageLoaderView()
        .frame(width: 100, height: 200)
        .anyButton(.highlight) {
            
        }
}
