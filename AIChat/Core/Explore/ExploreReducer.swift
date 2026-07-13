//
//  ExploreReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 13.07.2026.
//

import ComposableArchitecture

@Reducer
struct ExploreReducer {

    @Reducer
    enum Path {
        case category(CategoryListReducer)
        case chat(ChatReducer)
    }

    @ObservableState
    struct State: Equatable {
        var categories: [CharacterOption] = CharacterOption.allCases
        var featuredAvatars: [AvatarModel] = AvatarModel.mocks
        var path = StackState<Path.State>()
        var popularAvatars: [AvatarModel] = AvatarModel.mocks

        var filteredCategories: [CharacterOption] {
            categories.filter { category in
                popularAvatars.contains { $0.characterOption == category }
            }
        }
    }

    enum Action {
        case avatarTapped(AvatarModel)
        case categoryAvatarTapped(AvatarModel)
        case categoryTapped(category: CharacterOption, imageName: String)
        case path(StackActionOf<Path>)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .avatarTapped(avatar),
                let .categoryAvatarTapped(avatar):
                state.path.append(
                    .chat(
                        ChatReducer.State(
                            avatar: avatar,
                            avatarId: avatar.avatarId
                        )
                    )
                )
                return .none

            case let .categoryTapped(category, imageName):
                state.path.append(
                    .category(
                        CategoryListReducer.State(
                            avatars: state.popularAvatars.filter { $0.characterOption == category },
                            category: category,
                            imageName: imageName
                        )
                    )
                )
                return .none

            case let .path(.element(id: _, action: .category(.avatarTapped(avatar)))):
                return .send(.categoryAvatarTapped(avatar))

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path.body
        }
    }
}

extension ExploreReducer.Path.State: Equatable {}
