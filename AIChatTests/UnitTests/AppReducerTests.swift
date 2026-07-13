//
//  AppReducerTests.swift
//  AIChatTests
//
//  Created by macbook on 13.07.2026.
//

import ComposableArchitecture
import Testing
@testable import AIChat

@Suite("AppReducer tests")
struct AppReducerTests {
    private let deeplinkAvatar = AvatarModel.mock
    private let deeplinkUser = UserModel(
        userId: "deeplink-user",
        didCompleteOnboarding: true,
        profileColorHex: "#33FF57"
    )

    @Test
    func deepLinkBeforeSessionLoadIsStoredAsPending() async {
        let store = makeStore()

        await store.send(.deepLink(.profile)) {
            $0.pendingDeepLink = .profile
        }
    }

    @Test
    func pendingCategoryDeepLinkIsAppliedAfterSessionLoads() async {
        let store = makeStore(
            initialState: AppReducer.State(
                destination: .launching,
                pendingDeepLink: .category(.alien)
            )
        )

        await store.send(.sessionLoaded(didCompleteOnboarding: true, isNewUser: false)) {
            $0.pendingDeepLink = nil
            var tabBar = TabBarReducer.State()

            tabBar.selectedTab = .explore
            tabBar.explore.path.append(
                .category(
                    CategoryListReducer.State(
                        avatars: tabBar.explore.popularAvatars.filter {
                            $0.characterOption == .alien
                        },
                        category: .alien,
                        imageName: tabBar.explore.popularAvatars.first {
                            $0.characterOption == .alien
                        }?.profileImageName ?? Constants.randomImage
                    )
                )
            )
            $0.destination = .tabBar(tabBar)
        }

        #expect(store.state.pendingDeepLink == nil)

        guard let tabBar = tabBarState(
            from: store.state,
            issue: "Expected tabBar destination after loading session."
        ) else {
            return
        }

        #expect(tabBar.selectedTab == .explore)
        #expect(tabBar.explore.path.count == 1)

        guard case let .category(categoryState)? = tabBar.explore.path.first else {
            Issue.record("Expected first explore path element to be category.")
            return
        }

        #expect(categoryState.category == .alien)
        #expect(categoryState.avatars.allSatisfy { $0.characterOption == .alien })
        #expect(categoryState.imageName == categoryState.avatars.first?.profileImageName ?? Constants.randomImage)
    }

    @Test
    func chatDeepLinkRoutesToChatsTabAndPushesChat() async {
        let store = makeStore(
            initialState: AppReducer.State(
                destination: .tabBar(
                    TabBarReducer.State(
                        chats: ChatsReducer.State(
                            recentAvatars: [deeplinkAvatar]
                        ),
                        profile: ProfileReducer.State(
                            currentUser: deeplinkUser,
                            isLoading: false
                        )
                    )
                )
            )
        )

        await store.send(.deepLink(.chat(avatarId: deeplinkAvatar.avatarId))) {
            $0.pendingDeepLink = nil
            guard case var .tabBar(tabBar) = $0.destination else {
                Issue.record("Expected tabBar destination after chat deeplink.")
                return
            }

            tabBar.selectedTab = .chats
            tabBar.chats.path.append(
                .chat(
                    ChatReducer.State(
                        currentUser: deeplinkUser,
                        avatar: deeplinkAvatar,
                        avatarId: deeplinkAvatar.avatarId
                    )
                )
            )
            $0.destination = .tabBar(tabBar)
        }

        #expect(store.state.pendingDeepLink == nil)

        guard let tabBar = tabBarState(
            from: store.state,
            issue: "Expected tabBar destination after chat deeplink."
        ) else {
            return
        }

        #expect(tabBar.selectedTab == .chats)
        #expect(tabBar.chats.path.count == 1)
    }

    @Test
    func settingsDeepLinkRoutesToProfileAndPresentsSettings() async {
        let store = makeStore(
            initialState: AppReducer.State(
                destination: .tabBar(
                    TabBarReducer.State(
                        profile: ProfileReducer.State(
                            currentUser: UserModel.mock,
                            isLoading: false
                        )
                    )
                )
            )
        )

        await store.send(.deepLink(.settings)) {
            $0.pendingDeepLink = nil
            guard case var .tabBar(tabBar) = $0.destination else {
                Issue.record("Expected tabBar destination after settings deeplink.")
                return
            }

            tabBar.selectedTab = .profile
            tabBar.profile.settings = SettingsReducer.State(
                isAnonymousUser: false
            )
            $0.destination = .tabBar(tabBar)
        }

        #expect(store.state.pendingDeepLink == nil)

        guard let tabBar = tabBarState(
            from: store.state,
            issue: "Expected tabBar destination after settings deeplink."
        ) else {
            return
        }

        #expect(tabBar.selectedTab == .profile)
        #expect(tabBar.profile.settings?.isAnonymousUser == false)
    }

    private func makeStore(
        initialState: AppReducer.State = AppReducer.State()
    ) -> TestStore<AppReducer.State, AppReducer.Action> {
        TestStore(
            initialState: initialState
        ) {
            AppReducer()
        }
    }

    private func tabBarState(
        from state: AppReducer.State,
        issue: String
    ) -> TabBarReducer.State? {
        guard case let .tabBar(tabBar) = state.destination else {
            Issue.record(issue)
            return nil
        }

        return tabBar
    }
}
