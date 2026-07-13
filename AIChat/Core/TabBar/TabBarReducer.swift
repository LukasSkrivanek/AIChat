//
//  TabBarReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture

@Reducer
struct TabBarReducer {

    enum Tab: Hashable {
        case explore, chats, profile
    }

    @ObservableState
    struct State: Equatable {
        var chats = ChatsReducer.State()
        var explore = ExploreReducer.State()
        var selectedTab: Tab = .explore
        var profile = ProfileReducer.State()
    }

    enum Action {
        case chats(ChatsReducer.Action)
        case explore(ExploreReducer.Action)
        case selectedTabChanged(Tab)
        case profile(ProfileReducer.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.chats, action: \.chats) {
            ChatsReducer()
        }
        Scope(state: \.explore, action: \.explore) {
            ExploreReducer()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileReducer()
        }
        Reduce { state, action in
            switch action {
            case .chats:
                return .none

            case .explore:
                return .none

            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                return .none

            case .profile:
                return .none
            }
        }
    }
}
