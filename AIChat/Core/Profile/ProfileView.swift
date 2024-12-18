//
//  ProfileView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettingsView: Bool = false
    var body: some View {
        NavigationStack {
            Text("ProfileView")
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
                .sheet(isPresented: $showSettingsView) {
                    SettingsView()
                }
        }
        
    }
    private var settingsButton: some View {
        Button {
            onSettingsButtonPressed()
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
    }
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }
}

#Preview {
    ProfileView()
}
