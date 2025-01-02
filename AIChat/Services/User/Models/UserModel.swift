//
//  UserModel.swift
//  AIChat
//
//  Created by macbook on 31.12.2024.
//

import SwiftUI

struct UserModel {
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(userId: String, dateCreated: Date? = nil, didCompleteOnboarding: Bool? = nil, profileColorHex: String? = nil) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else {
            return .accent
        }
        return Color(hex: profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            .init(
                userId: "user_1",
                dateCreated: Date(),
                didCompleteOnboarding: true,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_2",
                dateCreated: Date().addingTimeInterval(hours: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_3",
                dateCreated: nil,
                didCompleteOnboarding: nil,
                profileColorHex: nil
            ),
            .init(
                userId: "user_4",
                dateCreated: Date().addingTimeInterval(hours: -4),
                didCompleteOnboarding: true,
                profileColorHex: "#3357FF"
            ),
            .init(
                userId: "user_5",
                dateCreated: Date().addingTimeInterval(hours: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#F3F315"
            )
        ]
    }
    
}
