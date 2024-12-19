//
//  TabCarouselView.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//

import SwiftUI

struct TabCarouselView<Item: Hashable, Content: View>: View {
    var items: [Item]
    @State private var selection: Int = 0
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        VStack {
            TabView(selection: $selection) {
                ForEach(items.indices, id: \.self) { index in
                    content(items[index])
                        .tag(index) // Matches the TabView selection to the index
                        .padding(.horizontal)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) 
            .frame(height: 200)
            
            // Custom Page Indicators (Optional)
            HStack(spacing: 8) {
                ForEach(items.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selection ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }
}

#Preview {
    TabCarouselView(items: AvatarModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subtitle: item.characterDescription,
            imageName: item.profileImageName
        )
    }
}
