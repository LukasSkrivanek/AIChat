//
//  MockAIService.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 25.05.2026.
//

import UIKit

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(3))
        return UIImage(systemName: "pencil")!
    }
}
