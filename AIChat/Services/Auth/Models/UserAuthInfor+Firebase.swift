//
//  UserAuthInfor+Firebase.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import AIChatDomain
import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.init(
            uid: user.uid,
            email: user.email,
            isAnonymous: user.isAnonymous,
            creationDate: user.metadata.creationDate,
            lastSignInDate: user.metadata.lastSignInDate
        )
    }
}
