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
                    Text(chat.id)
                }
            }
        }
    }
}

#Preview {
    ChatsView()
}
