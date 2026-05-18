//
//  ProfileReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CreateAvatarReducer {
    // TODO: Move CreateAvatar screen state and behavior into this reducer.
    @ObservableState
    struct State: Equatable {}

    enum Action {}

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            .none
        }
    }
}

@Reducer
struct ProfileReducer {
    @Reducer(state: .equatable)
    enum Destination {
        case chat(ChatReducer)
        case createAvatar(CreateAvatarReducer)
        case settings(SettingsReducer)
    }

    @Dependency(\.authManager)
    var authManager
    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        var currentUser: UserModel? = .mock
        var myAvatars: [AvatarModel] = []
        var isLoading: Bool = true
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case task
        case loadDataResult([AvatarModel])
        case settingsButtonTapped
        case newAvatarButtonTapped
        case avatarTapped(AvatarModel)
        case deleteAvatar(IndexSet)
        case delegate(Delegate)
        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        enum Delegate: Equatable {
            case didDeleteAccount
            case didSignOut
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .task:
                state.isLoading = true
                return .run { send in
                    await send(.loadDataResult(AvatarModel.mocks))
                }

            case .loadDataResult(let avatars):
                state.isLoading = false
                state.currentUser = userManager.currentUser
                state.myAvatars = avatars
                return .none

            case .settingsButtonTapped:
                state.destination = .settings(
                    SettingsReducer.State(
                    isAnonymousUser: authManager.auth?.isAnonymous == true
                    )
                )
                return .none

            case .destination(.presented(.settings(.delegate(.didDeleteAccount)))):
                state.destination = nil
                return .send(.delegate(.didDeleteAccount))

            case .destination(.presented(.settings(.delegate(.didSignOut)))):
                state.destination = nil
                return .send(.delegate(.didSignOut))

            case .newAvatarButtonTapped:
                state.destination = .createAvatar(CreateAvatarReducer.State())
                return .none

            case .avatarTapped(let avatar):
                state.destination = .chat(
                    ChatReducer.State(
                        chatMessages: [],
                        textFieldText: "",
                        scrollPosition: nil,
                        showProfileModal: false,
                        currentUser: state.currentUser,
                        avatar: avatar,
                        avatarId: avatar.avatarId,
                        alert: nil,
                        confirmationDialog: nil
                    )
                )
                return .none

            case .deleteAvatar(let indexSet):
                guard let index = indexSet.first else { return .none }
                state.myAvatars.remove(at: index)
                return .none

            case .delegate, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}
