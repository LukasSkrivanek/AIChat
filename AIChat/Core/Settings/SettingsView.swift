//
//  SettingsView.swift
//  AIChat
//
//  Created by macbook on 18.12.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSignOutPressed()
                } label: {
                    Text("sign out")
                }

            }
            .navigationTitle("Settings")
        }
        
    }
    func onSignOutPressed() {
        // do some logic to sign user out of
        dismiss()
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
