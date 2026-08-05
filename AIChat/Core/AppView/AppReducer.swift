//
//  AppReducer.swift
//  AIChat
//
//  Created by Skrivanek, Lukas on 17.03.2026.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppReducer {

    @Reducer
    enum Destination {
        case launching
        case onboarding(OnboardingReducer)
        case tabBar(TabBarReducer)
        case unlock(AppUnlockReducer)
        case welcome(WelcomeReducer)
    }

    enum PendingRoute: Equatable {
        case appLockSetup
    }

    @Dependency(\.appLockClient)
    var appLockClient
    @Dependency(\.biometricAuthClient)
    var biometricAuthClient
    @Dependency(\.sessionManager)
    var sessionManager
    @Dependency(\.userManager)
    var userManager

    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .launching
        @Presents var alert: AlertState<AlertAction>?
        var pendingDeepLink: DeepLink?
        var pendingRoute: PendingRoute?
        var postUnlockDestination: Destination.State?
    }

    enum Action {
        case deepLink(DeepLink)
        case destination(Destination.Action)
        case onAppear
        case refreshSession
        case sessionLoaded(didCompleteOnboarding: Bool, isNewUser: Bool)
        case sessionLoadFailed(String)
        case alert(PresentationAction<AlertAction>)
    }

    @CasePathable
    enum AlertAction: Equatable {
        case retryTapped
        case dismissTapped
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.destination, action: \.destination) {
            Destination.body
        }
        Reduce { state, action in
            switch action {
            case .deepLink(let deepLink):
                handleDeepLink(deepLink, state: &state)
                return .none

            case .onAppear, .refreshSession:
                state.pendingDeepLink = nil
                state.pendingRoute = nil
                state.postUnlockDestination = nil
                state.destination = .launching
                return .run { @MainActor send in
                    do {
                        let session = try await sessionManager.bootstrap()
                        send(
                            .sessionLoaded(
                                didCompleteOnboarding: session.didCompleteOnboarding,
                                isNewUser: session.isNewUser
                            )
                        )
                    } catch {
                        send(.sessionLoadFailed(errorMessage(for: error)))
                    }
                }

            case .sessionLoaded(let didCompleteOnboarding, let isNewUser):
                state.alert = nil
                let destination = authenticatedDestination(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
                enqueueAppLockSetupIfNeeded(
                    for: destination,
                    state: &state
                )
                routeAuthenticatedDestination(destination, state: &state)
                return .none

            case .sessionLoadFailed(let errorMessage):
                state.destination = .welcome(WelcomeReducer.State())
                state.alert = AlertState(
                    title: { TextState("Could not start app") },
                    actions: {
                        ButtonState(role: .cancel, action: .dismissTapped) {
                            TextState("OK")
                        }
                        ButtonState(action: .retryTapped) {
                            TextState("Try again")
                        }
                    },
                    message: {
                        TextState(errorMessage)
                    }
                )
                return .none

            case .alert(.presented(.retryTapped)):
                state.alert = nil
                return .send(.refreshSession)

            case .alert(.presented(.dismissTapped)):
                state.alert = nil
                return .none

            case .alert(.dismiss):
                return .none

            case .destination(.welcome(.delegate(.showOnboarding))):
                state.destination = .onboarding(OnboardingReducer.State())
                return .none

            case .destination(.welcome(.delegate(.didSignIn(let isNewUser, let didCompleteOnboarding)))):
                let destination = authenticatedDestination(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
                enqueueAppLockSetupIfNeeded(
                    for: destination,
                    state: &state
                )
                routeAuthenticatedDestination(destination, state: &state)
                return .none

            case .destination(.onboarding(.delegate(.didFinish))):
                let destination = authenticatedDestination(
                    didCompleteOnboarding: true,
                    isNewUser: false
                )
                enqueueAppLockSetupIfNeeded(
                    for: destination,
                    state: &state
                )
                routeAuthenticatedDestination(destination, state: &state)
                return .none

            case .destination(.unlock(.delegate(.didUnlock))):
                state.destination = state.postUnlockDestination ?? .tabBar(TabBarReducer.State())
                state.postUnlockDestination = nil
                handlePendingRoute(state: &state)
                handlePendingDeepLink(state: &state)
                return .none

            case .destination(.tabBar(.profile(.delegate(.didSignOut)))),
                 .destination(.tabBar(.profile(.delegate(.didDeleteAccount)))):
                return .send(.refreshSession)

            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func authenticatedDestination(
        didCompleteOnboarding: Bool,
        isNewUser: Bool = false
    ) -> Destination.State {
        if userManager.currentUser?.isAnonymous == true, didCompleteOnboarding {
            return .welcome(
                WelcomeReducer.State(
                    createAccount: CreateAccountReducer.State(
                        mode: .createAccount
                    )
                )
            )
        }

        if isNewUser || !didCompleteOnboarding {
            return .onboarding(OnboardingReducer.State())
        } else {
            return .tabBar(TabBarReducer.State())
        }
    }

    private func routeAuthenticatedDestination(
        _ destination: Destination.State,
        state: inout State
    ) {
        if shouldRequireUnlock(for: destination) {
            state.postUnlockDestination = destination
            state.destination = .unlock(
                AppUnlockReducer.State(
                    isBiometricUnlockEnabled: appLockClient.isBiometricUnlockEnabled(),
                    supportedBiometry: biometricAuthClient.biometryType()
                )
            )
        } else {
            state.postUnlockDestination = nil
            state.destination = destination
            handlePendingRoute(state: &state)
            handlePendingDeepLink(state: &state)
        }
    }

    private func enqueueAppLockSetupIfNeeded(
        for destination: Destination.State,
        state: inout State
    ) {
        guard shouldPromptForAppLockSetup(for: destination) else {
            return
        }

        state.pendingRoute = .appLockSetup
    }

    private func shouldRequireUnlock(
        for destination: Destination.State
    ) -> Bool {
        guard appLockClient.isEnabled() else {
            return false
        }

        guard case .tabBar = destination else {
            return false
        }

        return true
    }

    private func shouldPromptForAppLockSetup(
        for destination: Destination.State
    ) -> Bool {
        guard case .tabBar = destination else {
            return false
        }

        guard userManager.currentUser?.isAnonymous == false else {
            return false
        }

        return !appLockClient.hasPIN()
    }

    private func handlePendingDeepLink(state: inout State) {
        guard let pendingDeepLink = state.pendingDeepLink else {
            return
        }

        handleDeepLink(pendingDeepLink, state: &state)
    }

    private func handlePendingRoute(state: inout State) {
        guard let pendingRoute = state.pendingRoute else {
            return
        }

        state.pendingRoute = nil

        switch pendingRoute {
        case .appLockSetup:
            presentAppLockSetup(state: &state)
        }
    }

    private func handleDeepLink(
        _ deepLink: DeepLink,
        state: inout State
    ) {
        guard case var .tabBar(tabBar) = state.destination else {
            state.pendingDeepLink = deepLink
            return
        }

        state.pendingDeepLink = nil

        switch deepLink {
        case .appLockSetup:
            state.destination = .tabBar(tabBar)
            presentAppLockSetup(state: &state)
            return

        case .category(let category):
            tabBar.selectedTab = .explore
            tabBar.explore.path.append(
                .category(
                    CategoryListReducer.State(
                        avatarsResource: .loaded(
                            tabBar.explore.popularAvatars.filter {
                                $0.characterOption == category
                            }
                        ),
                        category: category,
                        imageName: tabBar.explore.popularAvatars.first {
                            $0.characterOption == category
                        }?.profileImageName ?? Constants.randomImage
                    )
                )
            )

        case .chat(let avatarId):
            tabBar.selectedTab = .chats
            tabBar.chats.path.append(
                .chat(
                    ChatReducer.State(
                        avatar: tabBar.chats.recentAvatars.first {
                            $0.avatarId == avatarId
                        },
                        avatarId: avatarId,
                        currentUser: tabBar.profile.currentUser
                    )
                )
            )

        case .profile:
            tabBar.selectedTab = .profile

        case .settings:
            tabBar.selectedTab = .profile
            tabBar.profile.settings = SettingsReducer.State(
                isAnonymousUser: tabBar.profile.isAnonymousUser
            )
        }

        state.destination = .tabBar(tabBar)
    }

    private func presentAppLockSetup(state: inout State) {
        guard case var .tabBar(tabBar) = state.destination else {
            state.pendingRoute = .appLockSetup
            return
        }

        let supportedBiometry = biometricAuthClient.biometryType()
        let isBiometricUnlockEnabled = appLockClient.isBiometricUnlockEnabled()
        let isAppLockEnabled = appLockClient.isEnabled()

        tabBar.selectedTab = .profile
        tabBar.profile.settings = SettingsReducer.State(
            appLockSetup: AppLockSetupReducer.State(
                isBiometricAvailable: supportedBiometry != .none,
                isBiometricEnabled: isBiometricUnlockEnabled,
                mode: isAppLockEnabled ? .changePIN : .setup
            ),
            isAppLockEnabled: isAppLockEnabled,
            isBiometricUnlockEnabled: isBiometricUnlockEnabled,
            isAnonymousUser: tabBar.profile.isAnonymousUser,
            supportedBiometry: supportedBiometry
        )

        state.destination = .tabBar(tabBar)
    }
}

extension AppReducer {
    private func errorMessage(for error: any Error) -> String {
        switch error {
        case let error as AuthServiceError:
            error.errorDescription ?? "Something went wrong."
        case let error as UserServiceError:
            error.errorDescription ?? "Something went wrong."
        default:
            error.localizedDescription
        }
    }
}

extension AppReducer.Destination.State: Equatable, Sendable {}
