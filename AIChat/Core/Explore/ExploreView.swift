//
//  ExploreView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct ExploreView: View {
    @Bindable var store: StoreOf<ExploreReducer>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                featureSection
                categoriesSection
                popularSection
            }
            .navigationTitle("Explore")
        } destination: { store in
            switch store.case {
            case let .category(store):
                CategoryListView(store: store)

            case let .chat(store):
                ChatView(store: store)
            }
        }
    }
    
    private var featureSection: some View {
        Section {
            switch store.featuredAvatarsResource {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .failed(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .loaded(let avatars):
                ZStack {
                    CarouselView(items: avatars) { avatar in
                        HeroCellView(
                            title: avatar.name,
                            subtitle: avatar.characterDescription,
                            imageName: avatar.profileImageName
                        )
                        .anyButton(.plain) {
                            store.send(.avatarTapped(avatar))
                        }
                    }
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Featured")
        }
    }
    private var categoriesSection: some View {
        Section {
            switch store.popularAvatarsResource {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .failed(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .loaded:
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(store.filteredCategories, id: \.self) { category in
                            let imageName = store.popularAvatars.first(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.rawValue,
                                    imageName: imageName
                                )
                                .clipped()
                                .frame(width: 150)
                                .anyButton(.plain) {
                                    store.send(.categoryTapped(category: category, imageName: imageName))
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
                .removeListRowFormatting()
            }
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            switch store.popularAvatarsResource {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .failed(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()

            case .loaded(let popularAvatars):
                ForEach(popularAvatars, id: \.self) { popularAvatar in
                    CustomListCellView(
                        imageName: popularAvatar.profileImageName,
                        title: popularAvatar.name,
                        subtitle: popularAvatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        store.send(.avatarTapped(popularAvatar))
                    }
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text("Popular")
        }
    }
}

#Preview {
    ExploreView(
        store: Store(initialState: ExploreReducer.State()) {
            ExploreReducer()
        }
    )
}
