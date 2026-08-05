//
//  CategoryListReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 13.07.2026.
//

import ComposableArchitecture
import LoadableAccessorMacros

@Reducer
struct CategoryListReducer {

    @ObservableState
    @LoadableAccessors
    struct State: Equatable {
        var avatarsResource: Loadable<[AvatarModel]> = .loaded(AvatarModel.mocks)
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
