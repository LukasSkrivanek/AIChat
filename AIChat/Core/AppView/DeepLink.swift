//
//  DeepLink.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 13.07.2026.
//

import Foundation

enum DeepLink: Equatable {
    case appLockSetup
    case category(CharacterOption)
    case chat(avatarId: String)
    case profile
    case settings
}

struct DeepLinkParser {
    func parse(_ url: URL) -> DeepLink? {
        guard url.scheme == "aichat" else {
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "category":
            guard
                let rawValue = pathComponents.first,
                let category = CharacterOption(rawValue: rawValue)
            else {
                return nil
            }

            return .category(category)

        case "chat":
            guard let avatarId = pathComponents.first else {
                return nil
            }

            return .chat(avatarId: avatarId)

        case "profile":
            return .profile

        case "settings":
            return .settings

        case "app-lock":
            return .appLockSetup

        default:
            return nil
        }
    }
}
