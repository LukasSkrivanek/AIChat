//
//  OpenAIAPIService.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 25.05.2026.
//

import UIKit
import FirebaseFunctions

struct OpenAIAPIService {
    func generateImage(input: String) async throws -> UIImage {
        
        let response = try await Functions.functions().httpsCallable("generateOpenAIImage").call([
            "input": input
        ])

        guard let b64Json = response.data as? String,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data)
        else {
            throw OpenAIError.invalidResponse
        }
        return image
    }

    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
}
