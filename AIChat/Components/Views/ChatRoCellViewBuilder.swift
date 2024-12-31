//
//  ChatRoCellViewBuilder.swift
//  AIChat
//
//  Created by macbook on 31.12.2024.
//

import SwiftUI

struct ChatRoCellViewBuilder: View {
    var currentUserId: String? = ""
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel?
    var getChatMessage: () async -> ChatMessageModel?
    
    @State fileprivate var avatar: AvatarModel?
    @State fileprivate  var lastMessage: ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var isLoading: Bool {
        !(didLoadAvatar && didLoadChatMessage)
    }
    
    private var subHeadline: String? {
        if isLoading {
            return "xxxx xxxx xxxxx"
        }
        if avatar == nil && lastMessage == nil {
            return "Error"
        }
        return lastMessage?.content
    }

    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxxx xxxx xxxxx" : avatar?.name,
            subheadline: subHeadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            // get the avatar
            avatar =  await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastMessage = await getChatMessage()
            didLoadChatMessage = true
        }
    }
    
    private var hasNewChat: Bool {
        guard let lastMessage, let currentUserId else { return false }
        return lastMessage.hasBeenSeenByCurrentUser(userId: currentUserId)
    }
}

#Preview {
    VStack {
        ChatRoCellViewBuilder(chat: .mock) {
            try? await Task.sleep(for: .seconds(5))
            return . mock
        } getChatMessage: {
            return .mock
        }
        
        ChatRoCellViewBuilder(chat: .mock) {
            return . mock
        } getChatMessage: {
            return .mock
        }
        ChatRoCellViewBuilder(chat: .mock) {
            return  nil
        } getChatMessage: {
            return nil
        }
    }
}
