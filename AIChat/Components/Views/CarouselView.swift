//
//  CarouselViewTemplate 2.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//
import SwiftUI

struct CarouselView<Item: Hashable, Content: View>: View {
    var items: [Item]
    @State private var selection: Item?
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .scrollTransition(.interactive.threshold(.visible(0.95)), transition: { content, phase in
                                content
                                    . scaleEffect(phase.isIdentity ? 1 : 0.9)
                            })
                            .containerRelativeFrame(.horizontal, alignment: .center)
                            .id(item)
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .onChange(of: items.count, { _, _ in
                updateSelectionIfNeeded()
            })
            .onAppear {
                updateSelectionIfNeeded()
            }
            
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(item == selection ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }

    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

#Preview {
    CarouselView(items: AvatarModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subtitle: item.characterDescription,
            imageName: item.profileImageName
        )
        .padding(.horizontal)
    }
}
