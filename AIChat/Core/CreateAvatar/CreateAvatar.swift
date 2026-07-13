//
//  CreateAvatar.swift
//  AIChat
//
//  Created by macbook on 07.01.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CreateAvatarReducer {

    @Dependency(\.aiManager)
    var aiManager
    @Dependency(\.continuousClock)
    var clock
    @Dependency(\.dismiss)
    var dismiss

    @ObservableState
    struct State: Equatable {
        var avatarName = ""
        var isSaving = false
        var isGenerating = false
        var generatedImage: UIImage?
        var characterOption: CharacterOption = .default
        var characterAction: CharacterAction = .default
        var characterLocation: CharacterLocation = .default
        var isLoading = false
        @Presents var alert: AlertState<AlertAction>?
    }

    enum Action: BindableAction {
        case alert(PresentationAction<AlertAction>)
        case binding(BindingAction<State>)
        case generateFinished(Result<UIImage, ImageGenerationError>)
        case onBackButtonPress
        case onGenerateImagePress
        case onSavePress
        case saveFinished
    }

    @CasePathable
    enum AlertAction: Equatable {
        case dismiss
    }

    struct ImageGenerationError: Equatable, LocalizedError {
        let message: String

        var errorDescription: String? {
            message
        }
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onSavePress:
                state.isSaving = true
                return .run { send in
                    try? await clock.sleep(for: .seconds(3))
                    await send(.saveFinished)
                }

            case .onGenerateImagePress:
                state.isGenerating = true
                let input = AvatarDescriptionBuilder(
                    characterOption: state.characterOption,
                    characterAction: state.characterAction,
                    characterLocation: state.characterLocation
                )
                .characterDescription
                return .run { send in
                    do {
                        let image = try await aiManager.generateImage(input: input)
                        await send(.generateFinished(.success(image)))
                    } catch {
                        await send(.generateFinished(.failure(ImageGenerationError(message: error.localizedDescription))))
                    }
                }

            case .onBackButtonPress:
                return .run { _ in
                    await dismiss()
                }

            case .saveFinished:
                state.isSaving = false
                return .run { _ in
                    await dismiss()
                }

            case .generateFinished(.success(let image)):
                state.generatedImage = image
                state.isGenerating = false
                return .none

            case .generateFinished(.failure(let error)):
                state.alert = AlertState {
                    TextState("Image generation failed")
                } actions: {
                    ButtonState(action: .dismiss) {
                        TextState("OK")
                    }
                } message: {
                    TextState(error.message)
                }
                state.isGenerating = false
                return .none

            case .alert, .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        BindingReducer()
    }
}

struct CreateAvatarView: View {

    @Bindable var store: StoreOf<CreateAvatarReducer>

    var body: some View {
        NavigationStack {
            List {
                nameSection()
                attributesSection()
                imageSection()
                saveSection()
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton()
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }

    private func imageSection() -> some View {
        Section {
            VStack(spacing: 16) {
                ZStack {
                    ProgressView()
                        .tint(.accent)
                        .opacity(store.isGenerating ? 1 : 0)

                    Text("Generate image")
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            store.send(.onGenerateImagePress)
                        }
                        .opacity(store.isGenerating ? 0 : 1)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .disabled(store.isGenerating || store.avatarName.isEmpty)

                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 220, height: 220)
                    .overlay {
                        ZStack {
                            if let generatedImage = store.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity)
            .removeListRowFormatting()
        }
    }

    private func attributesSection() -> some View {
        Section {
            Picker(selection: $store.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .tag(option)
                }
            } label: {
                Text("is a... ")
            }

            Picker(selection: $store.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue)
                        .tag(action)
                }
            } label: {
                Text("that is... ")
            }

            Picker(selection: $store.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue)
                        .tag(location)
                }
            } label: {
                Text("in the... ")
            }

        } header: {
            Text("Attributes")
        }
    }

    private func saveSection() -> some View {
        Section {
            AsyncCallToActionButton(
                isLoading: store.isSaving,
                title: "Save",
                action: { store.send(.onSavePress) }
            )
            .removeListRowFormatting()
            .opacity(store.generatedImage == nil ? 0.5 : 1)
            .disabled(store.generatedImage == nil)
        }
    }

    private func nameSection() -> some View {
        Section {
            TextField("Player 1", text: $store.avatarName)
        } header: {
            Text("Name your avatar")
        }
    }

    private func backButton() -> some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                store.send(.onBackButtonPress)
            }
    }
}

#Preview {
    let state = {
        var state = CreateAvatarReducer.State()
        state.avatarName = "Lukas"
        state.characterOption = .alien
        state.characterAction = .studying
        state.characterLocation = .space
        return state
    }()

    CreateAvatarView(
        store: Store(initialState: state) {
            CreateAvatarReducer()
        } withDependencies: {
            $0.aiManager = AIManager(service: MockAIService())
        }
    )
}
