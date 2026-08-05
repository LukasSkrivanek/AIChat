//
//  ChatsReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 13.07.2026.
//

import ComposableArchitecture
import LoadableAccessorMacros

@Reducer
struct ChatsReducer {

    @Reducer
    enum Path {
        case chat(ChatReducer)
    }

    @ObservableState
    @LoadableAccessors
    struct State: Equatable {
        var chatsResource: Loadable<[ChatModel]> = .loaded(ChatModel.mocks)
        var path = StackState<Path.State>()
        var recentAvatarsResource: Loadable<[AvatarModel]> = .loaded(AvatarModel.mocks)
    }

    enum Action {
        case avatarTapped(AvatarModel)
        case chatTapped(ChatModel)
        case path(StackActionOf<Path>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .avatarTapped(avatar):
                state.path.append(
                    .chat(
                        ChatReducer.State(
                            avatar: avatar,
                            avatarId: avatar.avatarId
                        )
                    )
                )
                return .none

            case let .chatTapped(chat):
                state.path.append(
                    .chat(
                        ChatReducer.State(
                            avatar: state.recentAvatars.first { $0.avatarId == chat.avatarId },
                            avatarId: chat.avatarId,
                            chatId: chat.id
                        )
                    )
                )
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path.body
        }
    }
}

extension ChatsReducer.Path.State: Equatable {}
