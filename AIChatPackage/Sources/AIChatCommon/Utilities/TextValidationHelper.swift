import Foundation

public enum TextValidationHelper {
    public static func checkTextFieldIsValid(text: String) throws {
        let minimumCharacterCount = 4

        guard text.count >= minimumCharacterCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacterCount)
        }

        let badWords: [String] = [
            "shit", "bitch", "ass",
        ]

        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }

    public enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords

        public var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Please add at least \(min) characters"
            case .hasBadWords:
                return "Bad word detected. Please rephrase your message"
            }
        }
    }
}
