//
//  ChatsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [ChatModel] = ChatModel.mocks
    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    ChatRoCellViewBuilder(
                        currentUserId: nil, // FIXME: Add cuid
                        chat: chat) {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        } getChatMessage: {
                            try? await Task.sleep(for: .seconds(1))
                            return .mock
                        }
                        .anyButton(.highlight) {
                            
                        }
                        .removeRowFormatting()
                }
                
            }
        }
    }
}

#Preview {
    ChatsView()
}
