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
    @State private var path: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $path) {
            List {
                featureSection
                categoriesSection
                popularSection
            }
            .navigationTitle("Explore")
            .navigationDestinationForCoreModule(path: $path)
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
                        onAvatarPress(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }
    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(filteredCategories, id: \.self) { category in
                        let imageName = popularAvatars.first(where: {$0.characterOption == category})?.profileImageName
                        if let imageName {
                            CategoryCellView(
                                title: category.rawValue,
                                imageName: imageName
                            )
                            .clipped()
                            .frame(width: 150)
                            .anyButton(.plain) {
                                onCategoryPress(category: category, imageName: imageName)
                            }
                            
                        }
                        
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    /// Filtrované kategorie, které mají odpovídající avatar
    private var filteredCategories: [CharacterOption] {
        categories.filter { category in
            popularAvatars.contains { $0.characterOption == category }
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
                    onAvatarPress(avatar: popularAvatar)
                }
                .removeListRowFormatting()
                
            }
            
        } header: {
            Text("Popular")
        }
        
    }
    private func onAvatarPress(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    private func onCategoryPress(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: Constants.randomImage ))
    }
}

#Preview {
    NavigationStack {
        ExploreView()
    }
}
