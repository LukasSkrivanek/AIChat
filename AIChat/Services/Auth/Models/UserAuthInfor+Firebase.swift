//
//  UserAuthInfor+Firebase.swift
//  AIChat
//
//  Created by macbook on 16.01.2025.
//
import FirebaseAuth

extension UserAuthInfo {
    init(user: User) {
        self.uId = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
    
}
