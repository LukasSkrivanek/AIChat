//
//  SessionManager+Dependency.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 01.06.2026.
//

import Dependencies

extension SessionManager: DependencyKey {
    static var liveValue: SessionManager {
        SessionManager()
    }
}

extension DependencyValues {
    var sessionManager: SessionManager {
        get { self[SessionManager.self] }
        set { self[SessionManager.self] = newValue }
    }
}
