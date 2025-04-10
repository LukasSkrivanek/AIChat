//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by macbook on 19.12.2024.
//

import SwiftUI

struct OnboardingColorView: View {
    @State private var selectedColor: Color?
    let profileColors: [Color] = [.red, .green, .orange, .blue, .purple, .mint, .cyan, .teal, .indigo]
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16, content: {
            ZStack {
                if let selectedColor {
                    ctaButton(selectedColor: selectedColor)
                        .transition(AnyTransition.move(edge: .bottom))
                }
                
            }
            .padding(24)
            .background(Color(uiColor: .systemBackground))
        })
        .animation(.smooth, value: selectedColor)
    }
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders]) {
                Section(header:
                            Text("Select a profile color")
                    .font(.headline)
                ) {
                    ForEach(profileColors, id: \.self) { loopedColor in
                        Circle()
                            .fill(.accent)
                            .overlay {
                                loopedColor
                                    .clipShape(Circle())
                                    .padding(selectedColor == loopedColor ? 10 : 0)
                            }
                            .onTapGesture {
                                selectedColor = loopedColor
                            }
                        
                    }
                }
            }
    }
    private func ctaButton(selectedColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor)
        } label: {
            Text("Continue")
                .callToActionButton()
                
        }
        .padding(24)
        
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .environment(AppState())
}
