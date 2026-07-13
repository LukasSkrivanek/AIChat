//
//  AIManager.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 25.05.2026.
//

import Observation
import UIKit

@Observable
final class AIManager {

    private let service: AIService

    init(service: AIService) {
        self.service = service
    }

    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
