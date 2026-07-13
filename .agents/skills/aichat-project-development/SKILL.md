---
name: aichat-project-development
description: Use when implementing or refactoring Swift code in this AIChat repository. Covers the project's TCA architecture, SwiftUI conventions, service and manager layering, dependency injection style, testing patterns, and repo-specific editing rules for features, reducers, views, and app flow.
---

# AIChat Project Development

Use this skill when writing product code for this repository.

Typical tasks:

- add or refactor a feature
- create a new reducer or view
- connect a screen into app flow
- add service logic
- inject dependencies
- write or update tests
- fix SwiftUI or TCA issues in app code

## Project shape

This project is a SwiftUI app built around the Composable Architecture.

Key folders:

- `AIChat/Core` for app flow, feature reducers, and feature views
- `AIChat/Components` for shared view pieces and modifiers
- `AIChat/Services` for auth, user, chat, avatar, and onboarding-related domain logic
- `AIChat/Extensions` for lightweight extensions
- `AIChatTests` for tests using `Testing` and `TestStore`

## Architectural defaults

### TCA first

Feature logic should usually live in a reducer under `AIChat/Core/...`.

Common pattern:

- `@Reducer struct FeatureReducer`
- `@ObservableState struct State`
- `enum Action`
- `var body: some Reducer<State, Action>`
- `FeatureView` receives `StoreOf<FeatureReducer>`

Prefer this style over moving logic into ad hoc view state unless the behavior is truly local and trivial.

Canonical examples in the repo:

- `AIChat/Core/AppView/AppReducer.swift`
- `AIChat/Core/Onboarding/OnboardingReducer.swift`
- `AIChat/Core/Profile/ProfileReducer.swift`
- `AIChat/Core/Chat/ChatReducer.swift`

For TCA-heavy work, prefer the existing project patterns first and use relevant Point-Free skills when they help match the current architecture, especially `pfw-composable-architecture`, `pfw-dependencies`, and `pfw-testing`.

### App flow

Global app routing lives in:

- `AIChat/Core/AppView/AppReducer.swift`
- `AIChat/Core/AppView/AppView.swift`

The app currently switches among:

- launching
- welcome
- onboarding
- tab bar

If a task changes entry flow, auth flow, onboarding completion, or sign-out behavior, inspect `AppReducer` first.

### Reducer composition

This repo uses modern TCA patterns such as:

- `Scope`
- `@Presents`
- `PresentationAction`
- `@CasePathable`

Match the existing style in nearby reducers instead of inventing a new one.

## Dependency style

### Use TCA dependencies in reducers

Reducer dependencies are injected with `@Dependency`.

Examples already in the project:

- `@Dependency(\\.userManager)`
- `@Dependency(\\.authManager)`
- `@Dependency(\\.continuousClock)`

If logic is reducer-owned and asynchronous, prefer adding a dependency instead of reaching directly into global singletons.

### Live dependency registration

Current live dependency registration is in `AIChat/Core/AppView/AppView.swift` via `DependencyKey` and `DependencyValues` extensions.

When adding a new cross-feature dependency:

1. create a lightweight client or manager API
2. expose a live value through `DependencyKey`
3. register it in `DependencyValues`
4. consume it from reducers with `@Dependency`

### Service and manager layering

The repo already has a useful layering pattern:

- `Service` protocols define the lower-level contract
- concrete Firebase or file-based implementations live under `Services/.../Services`
- `Manager` types coordinate app-facing state and behavior

Examples:

- `AuthService` -> `FirebaseAuthService` -> `AuthManager`
- user persistence and remote/local behavior under `Services/User`

If adding a new integration, prefer extending this layering instead of putting SDK calls directly in views or reducers.

## SwiftUI conventions

### Views

Views should stay mostly declarative and dispatch actions rather than own complex business logic.

Prefer:

- reducer-owned state for user flows
- small shared view pieces under `Components`
- preview helpers when a feature has multiple visual states

Keep side effects out of views unless the work is purely view-local.

### Main actor and UI-bound async work

If code interacts with UI-driven async APIs such as Apple sign-in or preview-only store setup, be mindful of `@MainActor`.

When CI or Xcode reports actor-isolation issues:

- inspect preview helpers
- inspect SwiftUI views
- inspect UI-facing async service entry points

Prefer a clean main-actor boundary over scattered one-off workarounds.

## Feature implementation recipe

For a new feature:

1. place reducer and primary view under `AIChat/Core/<Feature>`
2. follow nearby naming patterns like `FeatureReducer.swift` and `FeatureView.swift`
3. model all user interactions in `Action`
4. keep state explicit in `State`
5. use `@Dependency` for async work and side effects
6. connect the feature into parent routing or presentation in the parent reducer
7. add or update previews if the feature has meaningful visual states
8. add or update tests if reducer behavior changed

### Recipe: add a new TCA feature

For a typical new flow:

1. create `FeatureReducer.swift` under `AIChat/Core/<Feature>`
2. create `FeatureView.swift` beside it
3. define `State`, `Action`, and reducer body
4. add dependencies with `@Dependency` if needed
5. connect the feature from its parent reducer with `Scope`, destination state, or presentation
6. add a preview and at least one reducer test if behavior is non-trivial

### Recipe: add a new dependency-backed client

1. define the client or manager API
2. provide a live implementation
3. register it with `DependencyKey` and `DependencyValues`
4. consume it from reducers with `@Dependency`
5. override it in tests with `withDependencies`

### Recipe: add a modal, sheet, or alert flow

Prefer the existing TCA presentation style:

- `@Presents` in state
- `PresentationAction` in action
- `.ifLet` in the reducer body

Look at `WelcomeReducer`, `ProfileReducer`, and `SettingsReducer` before inventing a new approach.

## Testing conventions

Tests currently use:

- `import Testing`
- `@Suite`
- `@Test`
- `TestStore`
- explicit dependency overrides in `withDependencies`

Prefer reducer tests that assert state transitions after `store.send(...)`.

For deterministic tests:

- override `uuid`
- override `date.now`
- override any reducer dependency needed to remove randomness or I/O

If a feature is in TCA, prefer a `TestStore` test over ad hoc integration-style tests.

Canonical test example:

- `AIChatTests/AIChatTests.swift`

## Editing rules for this repo

- Preserve the existing TCA style and file organization.
- Prefer adding code near the feature that owns it.
- Do not commit `xcuserdata` or `UserInterfaceState.xcuserstate`.
- Keep SwiftLint config assumptions in mind if you add new top-level source locations.
- If a failure is in app code, fix the Swift file before changing CI.

## When to inspect specific files

- Open `AIChat/Core/AppView/AppReducer.swift` for auth flow, onboarding flow, or app start behavior.
- Open `AIChat/Core/AppView/AppView.swift` for dependency registration and root destination rendering.
- Open `AIChat/Core/Onboarding/OnboardingReducer.swift` for current reducer style, alert handling, and async profile completion.
- Open `AIChat/Services/Auth/Services/AuthService.swift` and nearby manager/service files when changing auth behavior.
- Open `AIChatTests/AIChatTests.swift` for the current test style baseline.

## Good defaults for agents

- Read the parent reducer before editing a child feature.
- Prefer following the nearest existing feature pattern over introducing a new abstraction.
- When changing async UI APIs, check whether `@MainActor` is the correct boundary.
- If a change affects flow between welcome, onboarding, and tab bar, inspect both `AppReducer` and the originating feature reducer.
- When a build fails in CI on app code, fix the app code first and only revisit workflow files if the failure is truly CI-specific.

## Response expectations

When making changes in this repo:

- explain the feature or bug at the reducer/view/service level
- mention the owning file, not just the symptom
- prefer minimal, idiomatic TCA changes
- keep fixes aligned with the project's current conventions
