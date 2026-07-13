//
//  AIManager+Dependency.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 01.06.2026.
//

import Dependencies

extension AIManager: DependencyKey {
    static var liveValue: AIManager {
        AIManager(service: OpenAIAPIService())
    }
}

extension DependencyValues {
    var aiManager: AIManager {
        get { self[AIManager.self] }
        set { self[AIManager.self] = newValue }
    }
}
