//
//  TabBarReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture

@Reducer
struct TabBarReducer {

    @ObservableState
    struct State: Equatable {
        var profile = ProfileReducer.State()
    }

    enum Action {
        case profile(ProfileReducer.Action)
        case delegate(Delegate)

        @CasePathable
        enum Delegate: Equatable {
            case userSignedOut
            case userDeletedAccount
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.profile, action: \.profile) {
            ProfileReducer()
        }
        Reduce { state, action in
            switch action {
            case .profile(.delegate(.userSignedOut)):
                return .send(.delegate(.userSignedOut))
            case .profile(.delegate(.userDeletedAccount)):
                return .send(.delegate(.userDeletedAccount))
            case .profile, .delegate:
                return .none
            }
        }
    }
}
