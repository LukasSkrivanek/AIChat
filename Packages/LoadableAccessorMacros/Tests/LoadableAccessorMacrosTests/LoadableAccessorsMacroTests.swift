#if canImport(LoadableAccessorMacrosPlugin)
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import LoadableAccessorMacrosPlugin

final class LoadableAccessorsMacroTests: XCTestCase {
    func testExpansion() {
        assertMacroExpansion(
            """
            @LoadableAccessors
            struct State {
                var chatsResource: Loadable<[ChatModel]> = .loaded([])
                var recentAvatarsResource: Loadable<[AvatarModel]> = .loaded([])
            }
            """,
            expandedSource: """
            @LoadableAccessors
            struct State {
                var chats: [ChatModel] {
                    get {
                        chatsResource.valueOrEmpty
                    }
                    set {
                        chatsResource = .loaded(newValue)
                    }
                }
                var recentAvatars: [AvatarModel] {
                    get {
                        recentAvatarsResource.valueOrEmpty
                    }
                    set {
                        recentAvatarsResource = .loaded(newValue)
                    }
                }
                var chatsResource: Loadable<[ChatModel]> = .loaded([])
                var recentAvatarsResource: Loadable<[AvatarModel]> = .loaded([])
            }
            """,
            macros: [
                "LoadableAccessors": LoadableAccessorsMacro.self
            ]
        )
    }
}
#endif
