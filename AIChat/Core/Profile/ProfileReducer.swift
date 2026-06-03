//
//  ProfileReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 15.05.2026.
//

import AIChatDomain
import ComposableArchitecture
import Foundation

@Reducer
struct ProfileReducer {

    @Reducer
    enum Path {
        case chat(ChatReducer)
    }
    
    @Reducer
    enum Destination {
        case createAvatar(CreateAvatarReducer)
        case settings(SettingsReducer)
    }

    @Dependency(\.userSessionClient)
    var userSessionClient

    @ObservableState
    struct State: Equatable {
        var currentUser: UserModel? = .mock
        var isLoading: Bool = true
        var myAvatars: [AvatarModel] = []
        
        var path = StackState<Path.State>()

        @Presents var destination: Destination.State?

        var isAnonymousUser: Bool {
            currentUser?.isAnonymous == true
        }
    }
    
    enum Action {
        case currentUserLoaded(UserModel?)
        case task
        case loadDataResult([AvatarModel])
        case settingsButtonTapped
        case newAvatarButtonTapped
        case avatarTapped(AvatarModel)
        case deleteAvatar(IndexSet)
        case delegate(DelegateAction)
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
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
                    .run { send in
                        let currentUser = await userSessionClient.currentUser()
                        await send(.currentUserLoaded(currentUser))
                    },
                    .run { send in
                        await send(.loadDataResult(AvatarModel.mocks))
                    }
                )

            case .currentUserLoaded(let currentUser):
                state.currentUser = currentUser
                if case var .settings(settingsState) = state.destination {
                    settingsState.isAnonymousUser = currentUser?.isAnonymous == true
                    state.destination = .settings(settingsState)
                }
                return .none

            case .loadDataResult(let avatars):
                state.isLoading = false
                state.myAvatars = avatars
                return .none

            case .settingsButtonTapped:
                state.destination = .settings(SettingsReducer.State(
                    isAnonymousUser: state.isAnonymousUser
                ))
                return .none

            case .destination(.presented(.settings(.delegate(.didFinishCreateAccount)))):
                return .run { send in
                    let currentUser = await userSessionClient.currentUser()
                    await send(.currentUserLoaded(currentUser))
                }

            case .destination(.presented(.settings(.delegate(.didDeleteAccount)))):
                state.destination = nil
                return .send(.delegate(.didDeleteAccount))

            case .destination(.presented(.settings(.delegate(.didSignOut)))):
                state.destination = nil
                return .send(.delegate(.didSignOut))

            case .newAvatarButtonTapped:
                state.destination = .createAvatar( CreateAvatarReducer.State())
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

            case .delegate, .destination, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ProfileReducer.Path.State: Equatable {}
extension ProfileReducer.Destination.State: Equatable {}
