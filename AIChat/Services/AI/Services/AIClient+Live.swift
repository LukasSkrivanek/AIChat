import Dependencies

extension AIClient: DependencyKey {
    static var liveValue: Self {
        let service = OpenAIAPIService()
        return Self(
            generateImage: service.generateImage
        )
    }

    static var testValue: Self {
        .unimplemented
    }
}

extension DependencyValues {
    var aiClient: AIClient {
        get { self[AIClient.self] }
        set { self[AIClient.self] = newValue }
    }
}
