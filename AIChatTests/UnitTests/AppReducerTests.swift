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
                        avatarsResource: .loaded(
                            tabBar.explore.popularAvatars.filter {
                                $0.characterOption == .alien
                            }
                        ),
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
            Issue.record(Comment(rawValue: "Expected first explore path element to be category."))
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
                            recentAvatarsResource: .loaded([deeplinkAvatar])
                        ),
                        profile: ProfileReducer.State(
                            currentUser: deeplinkUser,
                            isLoading: false,
                        )
                    )
                )
            )
        )

        await store.send(.deepLink(.chat(avatarId: deeplinkAvatar.avatarId))) {
            $0.pendingDeepLink = nil
            guard case var .tabBar(tabBar) = $0.destination else {
                Issue.record(Comment(rawValue: "Expected tabBar destination after chat deeplink."))
                return
            }

            tabBar.selectedTab = .chats
            tabBar.chats.path.append(
                .chat(
                    ChatReducer.State(
                        avatar: deeplinkAvatar,
                        avatarId: deeplinkAvatar.avatarId,
                        currentUser: deeplinkUser
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
                            isLoading: false,
                        )
                    )
                )
            )
        )

        await store.send(.deepLink(.settings)) {
            $0.pendingDeepLink = nil
            guard case var .tabBar(tabBar) = $0.destination else {
                Issue.record(Comment(rawValue: "Expected tabBar destination after settings deeplink."))
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

    @Test
    func appLockSetupDeepLinkRoutesToProfileAndPresentsSetup() async {
        let store = makeStore(
            initialState: AppReducer.State(
                destination: .tabBar(
                    TabBarReducer.State(
                        profile: ProfileReducer.State(
                            currentUser: UserModel.mock,
                            isLoading: false,
                        )
                    )
                )
            ),
            withDependencies: {
                $0.appLockClient = AppLockClient(
                    disable: {},
                    hasPIN: { false },
                    isBiometricUnlockEnabled: { true },
                    isEnabled: { false },
                    savePIN: { _ in },
                    setBiometricUnlockEnabled: { _ in },
                    verifyPIN: { _ in false }
                )
                $0.biometricAuthClient = BiometricAuthClient(
                    authenticate: { _ in },
                    biometryType: { .faceID }
                )
            }
        )

        await store.send(.deepLink(.appLockSetup)) {
            $0.pendingDeepLink = nil
            guard case var .tabBar(tabBar) = $0.destination else {
                Issue.record(Comment(rawValue: "Expected tabBar destination after app lock setup deeplink."))
                return
            }

            tabBar.selectedTab = .profile
            tabBar.profile.settings = SettingsReducer.State(
                appLockSetup: AppLockSetupReducer.State(
                    isBiometricAvailable: true,
                    isBiometricEnabled: true,
                    mode: .setup
                ),
                isAppLockEnabled: false,
                isBiometricUnlockEnabled: true,
                isAnonymousUser: false,
                supportedBiometry: .faceID
            )
            $0.destination = .tabBar(tabBar)
        }

        #expect(store.state.pendingDeepLink == nil)

        guard let tabBar = tabBarState(
            from: store.state,
            issue: "Expected tabBar destination after app lock setup deeplink."
        ) else {
            return
        }

        #expect(tabBar.selectedTab == .profile)
        #expect(tabBar.profile.settings?.appLockSetup?.mode == .setup)
    }

    @Test
    func sessionLoadedWithAppLockRoutesToUnlock() async {
        let store = makeStore(
            withDependencies: {
                $0.appLockClient = AppLockClient(
                    disable: {},
                    hasPIN: { true },
                    isBiometricUnlockEnabled: { true },
                    isEnabled: { true },
                    savePIN: { _ in },
                    setBiometricUnlockEnabled: { _ in },
                    verifyPIN: { $0 == "1234" }
                )
                $0.biometricAuthClient = BiometricAuthClient(
                    authenticate: { _ in },
                    biometryType: { .faceID }
                )
            }
        )

        await store.send(.sessionLoaded(didCompleteOnboarding: true, isNewUser: false)) {
            $0.destination = .unlock(
                AppUnlockReducer.State(
                    isBiometricUnlockEnabled: true,
                    supportedBiometry: .faceID
                )
            )
            $0.postUnlockDestination = .tabBar(TabBarReducer.State())
        }
    }

    @Test
    func sessionLoadedWithoutAppLockPresentsSetupFlow() async {
        let currentUser = UserModel(
            userId: "user-1",
            email: "lukas@example.com",
            isAnonymous: false,
            didCompleteOnboarding: true,
            profileColorHex: "#33FF57"
        )

        let store = makeStore(
            withDependencies: {
                $0.appLockClient = AppLockClient(
                    disable: {},
                    hasPIN: { false },
                    isBiometricUnlockEnabled: { true },
                    isEnabled: { false },
                    savePIN: { _ in },
                    setBiometricUnlockEnabled: { _ in },
                    verifyPIN: { _ in false }
                )
                $0.biometricAuthClient = BiometricAuthClient(
                    authenticate: { _ in },
                    biometryType: { .faceID }
                )
                $0.userManager = UserManager(
                    remoteService: MockUserService(user: currentUser),
                    localService: MockFileManagerUserPersistence(user: currentUser)
                )
            }
        )

        await store.send(.sessionLoaded(didCompleteOnboarding: true, isNewUser: false)) {
            $0.pendingDeepLink = nil
            var tabBar = TabBarReducer.State()
            tabBar.selectedTab = .profile
            tabBar.profile.settings = SettingsReducer.State(
                appLockSetup: AppLockSetupReducer.State(
                    isBiometricAvailable: true,
                    isBiometricEnabled: true,
                    mode: .setup
                ),
                isAppLockEnabled: false,
                isBiometricUnlockEnabled: true,
                isAnonymousUser: tabBar.profile.isAnonymousUser,
                supportedBiometry: .faceID
            )
            $0.destination = .tabBar(tabBar)
        }
    }

    @Test
    func unlockSuccessRoutesToStoredDestination() async {
        let store = makeStore(
            initialState: AppReducer.State(
                destination: .unlock(
                    AppUnlockReducer.State(
                        isBiometricUnlockEnabled: true,
                        supportedBiometry: .faceID
                    )
                ),
                postUnlockDestination: .tabBar(TabBarReducer.State())
            )
        )

        await store.send(.destination(.unlock(.delegate(.didUnlock)))) {
            $0.destination = .tabBar(TabBarReducer.State())
            $0.postUnlockDestination = nil
        }
    }

    @Test
    func onboardingFinishWithAnonymousUserRoutesToTabBarWithoutAppLockSetup() async {
        let currentUser = UserModel(
            userId: "anonymous-user",
            isAnonymous: true,
            didCompleteOnboarding: true,
            profileColorHex: "#33FF57"
        )

        let store = makeStore(
            initialState: AppReducer.State(
                destination: .onboarding(OnboardingReducer.State())
            ),
            withDependencies: {
                $0.appLockClient = AppLockClient(
                    disable: {},
                    hasPIN: { false },
                    isBiometricUnlockEnabled: { true },
                    isEnabled: { false },
                    savePIN: { _ in },
                    setBiometricUnlockEnabled: { _ in },
                    verifyPIN: { _ in false }
                )
                $0.biometricAuthClient = BiometricAuthClient(
                    authenticate: { _ in },
                    biometryType: { .faceID }
                )
                $0.userManager = UserManager(
                    remoteService: MockUserService(user: currentUser),
                    localService: MockFileManagerUserPersistence(user: currentUser)
                )
            }
        )

        await store.send(.destination(.onboarding(.delegate(.didFinish)))) {
            $0.destination = .tabBar(TabBarReducer.State())
        }
    }

    private func makeStore(
        initialState: AppReducer.State = AppReducer.State(),
        withDependencies updateDependencies: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore<AppReducer.State, AppReducer.Action> {
        TestStore(
            initialState: initialState
        ) {
            AppReducer()
        } withDependencies: {
            updateDependencies(&$0)
        }
    }

    private func tabBarState(
        from state: AppReducer.State,
        issue: String
    ) -> TabBarReducer.State? {
        guard case let .tabBar(tabBar) = state.destination else {
            Issue.record(Comment(rawValue: issue))
            return nil
        }

        return tabBar
    }
}
