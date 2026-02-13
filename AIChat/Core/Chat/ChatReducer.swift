//
//  ChatReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 20.12.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ChatReducer {
    
    @ObservableState
    struct State: Equatable {
        var chatMessages: [ChatMessageModel] = []
        var textFieldText = ""
        var scrollPosition: String?
        var showProfileModal = false
        var alert: AnyAppAlert?
        var currentUser: UserModel? = .mock
        var avatar: AvatarModel? = .mock
        var avatarId: String = AvatarModel.mock.avatarId
    }
    
    enum Action: BindableAction {
        case textChanged(String)
        case onChatSettingsTapped
        case deleteChatteTapped
        case reportUserTapped
        case onSendMessageTapped
        case toggleProfileModal
        case alertDismissed
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.textFieldText = text
                return .none
                
            case .onChatSettingsTapped:
                return .none
            case .deleteChatteTapped:
                // TODO: Implementation
                return .none
            case .reportUserTapped:
                // TODO: Implementation
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .toggleProfileModal:
                state.showProfileModal.toggle()
                return .none
            case .binding:
                return .none
            case .onSendMessageTapped:
                guard let currentUser = state.currentUser else {
                    return .none
                }
                let content = state.textFieldText
                do {
                    try TextValidationHelper.checkTextFieldIsValid(text: content)
                    let message = ChatMessageModel(
                        id: UUID().uuidString,
                        chatId: UUID().uuidString,
                        authorId: currentUser.userId,
                        content: content,
                        seenByIds: nil,
                        dateCreated: .now
                    )
                    
                    state.chatMessages.append(message)
                    state.scrollPosition = message.id
                    
                    state.textFieldText = ""
                } catch {
                    state.alert = AnyAppAlert(error: error)
                }
            }
            return .none
        }
        
    }
}
