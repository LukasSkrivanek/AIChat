import Foundation

public struct SessionBootstrap: Equatable, Sendable {
    public let didCompleteOnboarding: Bool
    public let isNewUser: Bool

    public init(
        didCompleteOnboarding: Bool,
        isNewUser: Bool
    ) {
        self.didCompleteOnboarding = didCompleteOnboarding
        self.isNewUser = isNewUser
    }
}

