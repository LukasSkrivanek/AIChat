import AIChatCommon
import Foundation

public struct FileManagerUserPersistence: Sendable {
    private let userDocumentKey = "current_user"

    public init() {
    }

    public func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }

    public func saveCurrentUser(_ user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
