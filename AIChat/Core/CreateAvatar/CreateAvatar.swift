//
//  CreateAvatar.swift
//  AIChat
//
//  Created by macbook on 07.01.2025.
//

import SwiftUI

struct CreateAvatar: View {
    @Environment(\.dismiss) private var dismiss
    @State private var avatarName: String = ""
    
    @State private var isSaving: Bool = false
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
        }
    }
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                        ProgressView()
                            .tint(.accent)
                            .opacity(isGenerating ? 1 : 0)
                  
                        Text("Generate image")
                            .underline()
                            .foregroundStyle(.accent)
                            .anyButton(.plain) {
                                onGenerateImagePress()
                            }
                            .opacity(isGenerating ? 0: 1)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                           
                        }
                    }
                    .clipShape(Circle())
            }
            .removeListRowFormatting()
        }
    }
    private var attributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                       .tag(option)
                }
            } label: {
                Text("is a... ")
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue)
                        .tag(action)
                }
            } label: {
                Text("that is... ")
            }
            
            Picker(selection: $characterLocation) {
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
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                title: "Save",
                action: onSavePress
            )
            .removeListRowFormatting()
            .opacity(generatedImage == nil ? 0.5 : 1)
        }
    }
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar")
        }
    }
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                onBackButtonPress()
            }
    }
    private func onBackButtonPress() {
        dismiss()
    }
    private func onGenerateImagePress() {
        isGenerating = true
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            generatedImage = UIImage(systemName: "star.fill")
            isGenerating = false
        }
    }
    private func onSavePress() {
        isSaving = true
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            isSaving = false
            dismiss()
        }
    }
}

#Preview {
    CreateAvatar()
}
