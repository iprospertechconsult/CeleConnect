//
//  ProfileView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import SwiftUI

struct ProfileView: View {
    @Binding var openSettings: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        Label("Edit Profile", systemImage: "pencil")
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Profile")
            // ✅ Modern replacement for isActive NavigationLink
            .navigationDestination(isPresented: $openSettings) {
                SettingsView()
            }
        }
    }
}
