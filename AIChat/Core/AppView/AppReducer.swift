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

    @Dependency(\.userManager)
    var userManager
    @Dependency(\.authManager)
    var authManager

    @ObservableState
    struct State: Equatable {
        var destination: Destination.State = .launching
        @Presents var alert: AlertState<AlertAction>?
    }

    enum Action {
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
            case .onAppear, .refreshSession:
                state.destination = .launching
                return .run { send in
                    do {
                        let session = try await loadSessionState()
                        await send(
                            .sessionLoaded(
                                didCompleteOnboarding: session.didCompleteOnboarding,
                                isNewUser: session.isNewUser
                            )
                        )
                    } catch {
                        await send(.sessionLoadFailed(errorMessage(for: error)))
                    }
                }

            case .sessionLoaded(let didCompleteOnboarding, let isNewUser):
                state.alert = nil
                state.destination = authenticatedDestination(
                    didCompleteOnboarding: didCompleteOnboarding,
                    isNewUser: isNewUser
                )
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
                return .none

            case .destination(.onboarding(.delegate(.didFinish))):
                state.destination = .tabBar(TabBarReducer.State())
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

    // MARK: - Private Methods
    private func loadSessionState() async throws -> (didCompleteOnboarding: Bool, isNewUser: Bool) {
        if let user = authManager.auth {
            print("User is authenticated: \(user.uId)")
            let currentUser = try await userManager.establishUserSession(auth: user, isNewUser: false)
            return (
                didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                isNewUser: false
            )
        } else {
            let result = try await authManager.signInAnonymously()
            print("Sign in anonymously: \(result.user.uId)")
            let currentUser = try await userManager.establishUserSession(auth: result.user, isNewUser: result.isNewUser)
            return (
                didCompleteOnboarding: currentUser.didCompleteOnboarding == true,
                isNewUser: result.isNewUser
            )
        }
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
