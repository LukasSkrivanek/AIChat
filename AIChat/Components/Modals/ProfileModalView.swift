//
//  ProfileModalView.swift
//  AIChat
//
//  Created by macbook on 08.01.2025.
//

import SwiftUI

struct ProfileModalView: View {
    var imageName: String? = Constants.randomImage
    var title: String? = "Alpha"
    var subtitle: String? = "Alien"
    var headline: String? = "An alien in the park"
    var onXMarkPress: () -> Void = { }
    var body: some View {
        VStack(spacing: 0) {
            if let imageName {
                ImageLoaderView(urlString: imageName, forceTransitionAnimation: true)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Image(systemName: "person")
            }
            
            VStack(alignment: .leading) {
                if let title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                if let headline {
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding( 24)     
        }
        .background(.thinMaterial)
        .cornerRadius(16)
        .overlay(
            Image(systemName: "xmark.circle.fill")
                .font(.title)
                .foregroundStyle(Color.black)
                .padding(4)
                .tappableBackground()
                .anyButton {
                    onXMarkPress()
                }
                .padding(8)
            
            , alignment: .topTrailing
        )
        .padding()
    }
}

#Preview("Modal w/ Image") {
    ZStack {
        Color.gray.ignoresSafeArea()
        ProfileModalView()
    }
    
}

#Preview("Profile w/out Image"){
    ZStack {
        Color.gray.ignoresSafeArea()
        ProfileModalView(imageName: nil)
    }
    
}
