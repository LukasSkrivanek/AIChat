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
        var selectedTab: Tab = .explore
        var profile = ProfileReducer.State()
    }

    enum Action {
        case selectedTabChanged(Tab)
        case profile(ProfileReducer.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileReducer()
        }
        Reduce { state, action in
            switch action {
            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                return .none
            case .profile:
                return .none
            }
        }
    }
}
