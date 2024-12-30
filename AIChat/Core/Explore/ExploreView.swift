//
//  ExploreView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct ExploreView: View {
    @State private var featuredAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [AvatarModel] = AvatarModel.mocks
    var body: some View {
        NavigationStack {
            List {
                featureSection
                categoriesSection
                popularSection
            }
            .navigationTitle("Explore")
        }
    }
    
    private var featureSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton(.plain) {
                        
                    }
                }
            }
            .removeRowFormatting()
        } header: {
            Text("Featured")
        }
    }
    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        ZStack {
                            CategoryCellView(
                                title: category.rawValue,
                                imageName: Constants.randomImage
                            )
                            .anyButton(.plain) {
                                
                            }
                        }
                        .clipped()
                        .frame(width: 150, height: 150)
                    }
                }
                
            }
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .removeRowFormatting()
        } header: {
            Text("Categories")
        }
        
    }
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { popularAvatar in
                CustomListCellView(
                    imageName: popularAvatar.profileImageName,
                    title: popularAvatar.name,
                    subtitle: popularAvatar.characterDescription
                )
                .anyButton(.highlight) {
                    
                }
                .removeRowFormatting()
            }
            
        } header: {
            Text("Popular")
        }
    }
}

#Preview {
    ExploreView()
}
