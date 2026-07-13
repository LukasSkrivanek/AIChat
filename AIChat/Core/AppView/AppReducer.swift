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
        case welcome(WelcomeReducer)
    }

    @Dependency(\.sessionManager)
    var sessionManager

    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .launching
        @Presents var alert: AlertState<AlertAction>?
        var pendingDeepLink: DeepLink?
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
                state.destination = authenticatedDestination(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
                handlePendingDeepLink(state: &state)
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
                state.destination = authenticatedDestination(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
                handlePendingDeepLink(state: &state)
                return .none

            case .destination(.onboarding(.delegate(.didFinish))):
                state.destination = .tabBar(TabBarReducer.State())
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
        if isNewUser || !didCompleteOnboarding {
            return .onboarding(OnboardingReducer.State())
        } else {
            return .tabBar(TabBarReducer.State())
        }
    }

    private func handlePendingDeepLink(state: inout State) {
        guard let pendingDeepLink = state.pendingDeepLink else {
            return
        }

        handleDeepLink(pendingDeepLink, state: &state)
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
        case .category(let category):
            tabBar.selectedTab = .explore
            tabBar.explore.path.append(
                .category(
                    CategoryListReducer.State(
                        avatars: tabBar.explore.popularAvatars.filter {
                            $0.characterOption == category
                        },
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
                        avatarId: avatarId
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
