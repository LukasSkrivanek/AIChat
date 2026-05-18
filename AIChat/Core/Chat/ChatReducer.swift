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
        var currentUser: UserModel? = .mock
        var avatar: AvatarModel? = .mock
        var avatarId: String = AvatarModel.mock.avatarId
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var confirmationDialog: ConfirmationDialogState<Action.ConfirmationDialog>?
    }
    
    enum Action: BindableAction {
        case textChanged(String)
        case onChatSettingsTapped
        case deleteChatTapped
        case reportUserTapped
        case onSendMessageTapped
        case toggleProfileModal
        case binding(BindingAction<State>)
        case alert(PresentationAction<Alert>)
        case confirmationDialog(PresentationAction<ConfirmationDialog>)

        @CasePathable
        enum Alert: Equatable {
            case alertCancelTapped
            case alertConfirmTapped
        }

        @CasePathable
        enum ConfirmationDialog: Equatable {
            case confirmationDialogCancelTapped
            case confirmationDialogConfirmTapped
        }
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
                    let message = ChatMessageModel(
                        id: uuid().uuidString,
                        chatId: uuid().uuidString,
                        authorId: currentUser.userId,
                        content: content,
                        seenByIds: nil,
                        dateCreated: date()
                    )
                    
                    state.chatMessages.append(message)
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
        // Integrate presentation for alerts (no child reducer needed)
    }
}
