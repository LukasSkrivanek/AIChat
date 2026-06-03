import UIKit

struct AIClient: Sendable {
    var generateImage: @Sendable (String) async throws -> UIImage

    init(
        generateImage: @escaping @Sendable (String) async throws -> UIImage
    ) {
        self.generateImage = generateImage
    }
}

extension AIClient {
    static let unimplemented = Self(
        generateImage: { _ in
            fatalError("AIClient.generateImage unimplemented")
        }
    )

    static var previewValue: Self {
        .mock()
    }

    static func mock() -> Self {
        Self(
            generateImage: { _ in
                try await Task.sleep(for: .seconds(3))
                return UIImage(systemName: "pencil")!
            }
        )
    }
}
