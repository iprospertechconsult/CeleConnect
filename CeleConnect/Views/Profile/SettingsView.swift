//
//  SettingsView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Text("Account")
            Text("Notifications")
            Text("Privacy")
            Text("Logout")
                .foregroundStyle(.red)
        }
        .navigationTitle("Settings")
    }
}
