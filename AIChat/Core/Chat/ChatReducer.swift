//
//  ChatReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 20.12.2025.
//

import ComposableArchitecture
import LoadableAccessorMacros
import SwiftUI

@Reducer
struct ChatReducer {
    
    @ObservableState
    @LoadableAccessors
    struct State: Equatable {
        var avatar: AvatarModel? = .mock
        var avatarId: String = AvatarModel.mock.avatarId
        var chatId: String?
        var chatMessagesResource: Loadable<[ChatMessageModel]> = .loaded([])
        var currentUser: UserModel? = .mock
        var textFieldText = ""
        var scrollPosition: String?
        var showProfileModal = false
        @Presents var alert: AlertState<AlertAction>?
        @Presents var confirmationDialog: ConfirmationDialogState<ConfirmationDialogAction>?
    }
    
    enum Action: BindableAction {
        case textChanged(String)
        case onChatSettingsTapped
        case deleteChatTapped
        case reportUserTapped
        case onSendMessageTapped
        case toggleProfileModal
        case binding(BindingAction<State>)
        case alert(PresentationAction<AlertAction>)
        case confirmationDialog(PresentationAction<ConfirmationDialogAction>)
    }

    @CasePathable
    enum AlertAction: Equatable {
        case alertCancelTapped
        case alertConfirmTapped
    }

    @CasePathable
    enum ConfirmationDialogAction: Equatable {
        case confirmationDialogCancelTapped
        case confirmationDialogConfirmTapped
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .textChanged(text):
                state.textFieldText = text
                return .none
                
            case .onChatSettingsTapped:
                return .none
            case .deleteChatTapped:
                // TODO: Implementation
                return .none
            case .reportUserTapped:
                // TODO: Implementation
                return .none

            case .alert(.presented(.alertCancelTapped)):
                state.alert = nil
                return .none

            case .alert(.presented(.alertConfirmTapped)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                // Alert dismissed by system; state will be nilled by presentation reducer automatically.
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
                    if state.chatId == nil {
                        state.chatId = uuid().uuidString
                    }
                    guard let chatId = state.chatId
                    else {
                        return .none
                    }
                    let message = ChatMessageModel(
                        id: uuid().uuidString,
                        chatId: chatId,
                        authorId: currentUser.userId,
                        content: content,
                        seenByIds: nil,
                        dateCreated: date()
                    )
                    
                    var chatMessages = state.chatMessages
                    chatMessages.append(message)
                    state.chatMessagesResource = .loaded(chatMessages)
                    state.scrollPosition = message.id
                    
                    state.textFieldText = ""
                } catch {
                    state.alert = AlertState {
                        TextState("Alert!")
                    } actions: {
                        ButtonState(role: .cancel, action: .send(.alertCancelTapped)) {
                            TextState("Cancel")
                        }
                        ButtonState(action: .send(.alertConfirmTapped)) {
                            TextState("OK")
                        }
                    } message: {
                        TextState((error as? LocalizedError)?.errorDescription ?? "This is an alert")
                    }
                }
            case .confirmationDialog:
                return .none
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$confirmationDialog, action: \.confirmationDialog)
    }
}
