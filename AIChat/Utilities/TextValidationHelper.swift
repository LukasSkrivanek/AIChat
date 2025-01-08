//
//  TextValidationHelper.swift
//  AIChat
//
//  Created by macbook on 08.01.2025.
//
import Foundation

struct TextValidationHelper {
    
    static func checkTextFieldIsValid(text: String) throws {
        let minimumCharacterCount = 4
        
        guard text.count >=  minimumCharacterCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacterCount)
        }
        
        let badWords: [String] = [
            "shit", "bitch", "ass"
        ]
        
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
    
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters"
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message"
            }
        }
    }

}
