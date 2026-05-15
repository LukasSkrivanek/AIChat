//
//  ProfileReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ProfileReducer {

    @ObservableState
    struct State: Equatable {
        var currentUser: UserModel? = .mock
        var myAvatars: [AvatarModel] = []
        var isLoading: Bool = true
        var path: [NavigationPathOption] = []
        var showCreateAvatar: Bool = false
        @Presents var settings: SettingsReducer.State?
    }

    enum Action {
        case task
        case loadDataResult([AvatarModel])
        case settingsButtonTapped
        case newAvatarButtonTapped
        case createAvatarDismissed
        case avatarTapped(AvatarModel)
        case deleteAvatar(IndexSet)
        case pathChanged([NavigationPathOption])
        case settings(PresentationAction<SettingsReducer.Action>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { send in
                    try? await Task.sleep(for: .seconds(4))
                    await send(.loadDataResult(AvatarModel.mocks))
                }

            case .loadDataResult(let avatars):
                state.isLoading = false
                state.myAvatars = avatars
                return .none

            case .settingsButtonTapped:
                state.settings = SettingsReducer.State()
                return .none

            case .newAvatarButtonTapped:
                state.showCreateAvatar = true
                return .none

            case .createAvatarDismissed:
                state.showCreateAvatar = false
                return .none

            case .avatarTapped(let avatar):
                state.path.append(.chat(avatarId: avatar.avatarId))
                return .none

            case .deleteAvatar(let indexSet):
                guard let index = indexSet.first else { return .none }
                state.myAvatars.remove(at: index)
                return .none

            case .pathChanged(let path):
                state.path = path
                return .none

            case .settings:
                return .none
            }
        }
        .ifLet(\.$settings, action: \.settings) {
            SettingsReducer()
        }
    }
}
