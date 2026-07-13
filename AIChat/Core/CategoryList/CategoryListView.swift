//
//  CategoryListVeiw.swift
//  AIChat
//
//  Created by macbook on 13.01.2025.
//

import SwiftUI
import ComposableArchitecture

struct CategoryListView: View {
    let store: StoreOf<CategoryListReducer>

    var body: some View {
        List {
            CategoryCellView(
                title: store.category.plural.capitalized,
                imageName: store.imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            ForEach(store.avatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    store.send(.avatarTapped(avatar))
                }
            }
        }
        .ignoresSafeArea()
        .listStyle(.plain)
    }
}

#Preview {
    CategoryListView(
        store: Store(initialState: CategoryListReducer.State()) {
            CategoryListReducer()
        }
    )
}
