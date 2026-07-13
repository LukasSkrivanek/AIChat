//
//  CategoryListReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 13.07.2026.
//

import ComposableArchitecture

@Reducer
struct CategoryListReducer {

    @ObservableState
    struct State: Equatable {
        var avatars: [AvatarModel] = AvatarModel.mocks
        var category: CharacterOption = .alien
        var imageName: String = Constants.randomImage
    }

    enum Action {
        case avatarTapped(AvatarModel)
    }

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .avatarTapped:
                return .none
            }
        }
    }
}
