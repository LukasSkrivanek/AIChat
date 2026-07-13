//
//  DeepLinkParserTests.swift
//  AIChatTests
//
//  Created by macbook on 13.07.2026.
//

import Foundation
import Testing
@testable import AIChat

@Suite("DeepLinkParser tests")
struct DeepLinkParserTests {

    @Test
    func parsesCategoryDeepLink() {
        #expect(parse("aichat://category/alien") == .category(.alien))
    }

    @Test
    func parsesChatDeepLink() {
        #expect(parse("aichat://chat/avatar-123") == .chat(avatarId: "avatar-123"))
    }

    @Test
    func parsesProfileDeepLink() {
        #expect(parse("aichat://profile") == .profile)
    }

    @Test
    func rejectsInvalidScheme() {
        #expect(parse("https://profile") == nil)
    }

    @Test
    func rejectsUnknownCategory() {
        #expect(parse("aichat://category/robot") == nil)
    }

    private func parse(_ urlString: String) -> DeepLink? {
        DeepLinkParser().parse(makeURL(urlString))
    }

    private func makeURL(_ urlString: String) -> URL {
        URL(string: urlString)!
    }
}
