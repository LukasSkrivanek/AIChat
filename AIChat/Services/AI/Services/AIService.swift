//
//  AIService.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 25.05.2026.
//

import UIKit

protocol AIService {
    func generateImage(input: String) async throws -> UIImage
}
