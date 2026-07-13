---
name: ios-ci-troubleshooting
description: Use when diagnosing or improving this repository's GitHub Actions, SwiftLint, Xcode build, simulator test failures, Swift package macro trust issues, or pull request CI regressions. Especially relevant for fixes in .github/workflows/ci.yml, .github/workflows/workflow-lint.yml, AIChat/.swiftlint.yml, and related Swift files that break CI.
---

# iOS CI Troubleshooting

Use this skill for CI work in this repository.

Typical triggers:

- failing GitHub Actions runs
- broken pull request checks
- SwiftLint touching `.spm` or generated files
- `xcodebuild test` failures
- simulator discovery issues
- package macro or plugin trust errors
- Swift compile errors that appear only in CI

## Repo anchors

- Workflow: `.github/workflows/ci.yml`
- Workflow lint: `.github/workflows/workflow-lint.yml`
- SwiftLint config: `AIChat/.swiftlint.yml`
- Project: `AIChat.xcodeproj`
- Scheme: `AIChat`
- Tests: `AIChatTests`, `AIChatUITests`

## Default approach

1. Open the current workflow files first.
2. Find the first real `error:` line in the log.
3. Ignore dependency graph noise unless package resolution itself failed.
4. Decide whether the problem is:
   - workflow configuration
   - package resolution
   - macro/plugin trust
   - simulator selection
   - SwiftLint scope
   - app code compile failure
   - test assertion failure
5. Fix app code when the failure is in app code. Do not overcomplicate CI to hide source issues.

## Known-good repo patterns

### Workflow triggers

The main workflow should run on:

```yml
on:
  pull_request:
  workflow_dispatch:
```

This repo intentionally does not need a plain `push` trigger for the main iOS workflow.

### Xcode and runner

- runner: `macos-15`
- Xcode: `16.4`

### Test execution

Prefer one direct `xcodebuild test` invocation over more complex split flows unless there is a clear need.

### Macro and plugin trust

This repo uses Point-Free packages with macros and plugins. If CI shows errors like:

- `Macro "... must be enabled before it can be used"`

check for these in the workflow:

```bash
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
```

and these flags on `xcodebuild test`:

```bash
-skipMacroValidation
-skipPackagePluginValidation
```

### SwiftLint scope

`AIChat/.swiftlint.yml` is not at repo root, so `included` and `excluded` paths are relative to `AIChat/`.

Known-good include scope:

```yml
included:
  - .
  - ../AIChatTests
  - ../AIChatUITests
```

Keep `.spm` and `.derivedData` excluded, and run:

```bash
swiftlint lint --config AIChat/.swiftlint.yml
```

Do not pass repo-root positional paths unless verified.

### Simulator selection

Prefer dynamic selection from `xcodebuild -showdestinations`. Avoid fragile hardcoded simulator names when a filtered available iPhone device works.

## Repo-specific failure patterns

### Stale PR checks

PR timelines may show failed runs from older commits. Always confirm the failing run belongs to the newest commit before changing code.

### Swift 6 / Xcode 16 actor issues

If CI reports:

- `Expression is 'async' but is not marked with 'await'`

check:

- `@MainActor` isolation on SwiftUI preview helpers and views
- main-actor-isolated Apple sign-in helpers

For Apple sign-in UI code, prefer a clean `@MainActor` fix around the async sign-in function when appropriate.

### Preview-only breakage

If previews fail in CI, inspect preview helper types and preview views before touching workflow YAML.

## Delivery rules

- State which file is actually broken.
- Distinguish CI setup problems from source-code problems.
- Prefer minimal patches.
- Never commit:
  - `AIChat.xcodeproj/project.xcworkspace/xcuserdata/...`
  - `UserInterfaceState.xcuserstate`
