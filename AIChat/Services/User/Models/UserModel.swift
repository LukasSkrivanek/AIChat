//
//  UserModel.swift
//  AIChat
//
//  Created by macbook on 31.12.2024.
//

import SwiftUI

struct UserModel: Codable, Equatable, Sendable {
    let userId: String
    let email: String?
    let phoneNumber: String?
    let isPhoneVerified: Bool?
    let isAnonymous: Bool?
    let creationDate: Date?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    let creationVersion: String?
    
    init(
        userId: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        isPhoneVerified: Bool? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        creationVersion: String? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.phoneNumber = phoneNumber
        self.isPhoneVerified = isPhoneVerified
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    init(auth: UserAuthInfo, creationVersion: String ) {
        self.init(
            userId: auth.uId,
            email: auth.email,
            isAnonymous: auth.isAnonymous,
            creationDate: auth.creationDate,
            lastSignInDate: auth.lastSignInDate,
            creationVersion: creationVersion
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case phoneNumber = "phone_number"
        case isPhoneVerified = "is_phone_verified"
        case isAnonymous = "is_anonymous"
        case creationVersion = "creation_version"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
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
        let baseDate = Date(timeIntervalSinceReferenceDate: 1_234_567_890)

        return [
            .init(
                userId: "user_1",
                creationDate: baseDate,
                didCompleteOnboarding: true,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_2",
                creationDate: baseDate.addingTimeInterval(hours: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#33FF57"
            ),
            .init(
                userId: "user_3",
                creationDate: nil,
                didCompleteOnboarding: nil,
                profileColorHex: nil
            ),
            .init(
                userId: "user_4",
                creationDate: baseDate.addingTimeInterval(hours: -4),
                didCompleteOnboarding: true,
                profileColorHex: "#3357FF"
            ),
            .init(
                userId: "user_5",
                creationDate: baseDate.addingTimeInterval(hours: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#F3F315"
            )
        ]
    }
    
}
