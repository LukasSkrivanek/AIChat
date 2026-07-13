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

    @Reducer
    enum Path {
        case chat(ChatReducer)
    }

    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        var currentUser: UserModel? = .mock
        @Presents var createAvatar: CreateAvatarReducer.State?
        var isLoading: Bool = true
        var myAvatars: [AvatarModel] = []
        var path = StackState<Path.State>()
        @Presents var settings: SettingsReducer.State?

        var isAnonymousUser: Bool {
            currentUser?.isAnonymous == true
        }
    }
    
    enum Action {
        case currentUserLoaded(UserModel?)
        case createAvatar(PresentationAction<CreateAvatarReducer.Action>)
        case task
        case loadDataResult([AvatarModel])
        case settingsButtonTapped
        case newAvatarButtonTapped
        case avatarTapped(AvatarModel)
        case deleteAvatar(IndexSet)
        case delegate(DelegateAction)
        case path(StackActionOf<Path>)
        case settings(PresentationAction<SettingsReducer.Action>)
    }

    @CasePathable
    enum DelegateAction: Equatable {
        case didDeleteAccount
        case didSignOut
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .merge(
                    .run { @MainActor send in
                        send(.currentUserLoaded(userManager.currentUser))
                    },
                    .run { send in
                        await send(.loadDataResult(AvatarModel.mocks))
                    }
                )

            case .currentUserLoaded(let currentUser):
                state.currentUser = currentUser
                state.settings?.isAnonymousUser = currentUser?.isAnonymous == true
                return .none

            case .loadDataResult(let avatars):
                state.isLoading = false
                state.myAvatars = avatars
                return .none

            case .settingsButtonTapped:
                state.settings = SettingsReducer.State(
                    isAnonymousUser: state.isAnonymousUser
                )
                return .none

            case .settings(.presented(.delegate(.didFinishCreateAccount))):
                return .run { @MainActor send in
                    send(.currentUserLoaded(userManager.currentUser))
                }

            case .settings(.presented(.delegate(.didDeleteAccount))):
                state.settings = nil
                return .send(.delegate(.didDeleteAccount))

            case .settings(.presented(.delegate(.didSignOut))):
                state.settings = nil
                return .send(.delegate(.didSignOut))

            case .newAvatarButtonTapped:
                state.createAvatar = CreateAvatarReducer.State()
                return .none

            case .avatarTapped(let avatar):
                state.path.append(
                    .chat(
                        ChatReducer.State(
                            currentUser: state.currentUser,
                            avatar: avatar,
                            avatarId: avatar.avatarId
                        )
                    )
                )
                return .none

            case .deleteAvatar(let indexSet):
                guard let index = indexSet.first else { return .none }
                state.myAvatars.remove(at: index)
                return .none

            case .createAvatar, .delegate, .settings, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$createAvatar, action: \.createAvatar) {
            CreateAvatarReducer()
        }
        .ifLet(\.$settings, action: \.settings) {
            SettingsReducer()
        }
    }
}

extension ProfileReducer.Path.State: Equatable {}
