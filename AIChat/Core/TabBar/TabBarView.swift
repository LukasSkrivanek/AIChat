//
//  TabBarView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI
import ComposableArchitecture

struct TabBarView: View {

    let store: StoreOf<TabBarReducer>

    var body: some View {
        TabView {
            NavigationStack {
                ExploreView()
                    .navigationTitle("Explore")
            }
            .tabItem {
                Label("Explore", systemImage: "eyes")
            }

            NavigationStack {
                ChatsView()
                    .navigationTitle("Chats")
            }
            .tabItem {
                Label("Chats", systemImage: "bubble.left.and.bubble.right.fill")
            }

            NavigationStack {
                ProfileView(store: store.scope(state: \.profile, action: \.profile))
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
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
