//
//  TabBarView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct TabBarView: View {

    @Bindable var store: StoreOf<TabBarReducer>

    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
            ExploreView(store: store.scope(state: \.explore, action: \.explore))
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }
            .tag(TabBarReducer.Tab.explore)

            ChatsView(store: store.scope(state: \.chats, action: \.chats))
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(TabBarReducer.Tab.chats)

            ProfileView(store: store.scope(state: \.profile, action: \.profile))
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(TabBarReducer.Tab.profile)
        }
    }
}

#Preview {
    TabBarView(
        store: Store(initialState: TabBarReducer.State()) {
            TabBarReducer()
        }
    )
}
