//
//  EditProfileView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import SwiftUI

struct EditProfileView: View {
    // Later: inject a VM that loads/saves current user
    @State private var draft = EditProfileDraft.mock

    var body: some View {
        List {
            Section("Photos") {
                PhotosRow(urls: draft.photoURLs)
                NavigationLink("Edit Photos") {
                    EditPhotosView(draft: $draft)
                }
            }

            Section("About") {
                LabeledRow(title: "Name", value: draft.firstName)
                LabeledRow(title: "City", value: draft.city)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bio").font(.caption).foregroundStyle(.secondary)
                    Text(draft.bio.isEmpty ? "Add a bio…" : draft.bio)
                        .foregroundStyle(draft.bio.isEmpty ? .secondary : .primary)
                        .lineLimit(3)
                }
                NavigationLink("Edit About") {
                    EditAboutView(draft: $draft)
                }
            }

            Section("Basics") {
                LabeledRow(title: "Gender", value: draft.gender)
                LabeledRow(title: "Looking For", value: draft.lookingFor)
                LabeledRow(title: "Religion", value: draft.religion ?? "—")
                NavigationLink("Edit Basics") {
                    EditBasicsView(draft: $draft)
                }
            }

            Section("Discovery") {
                Toggle("Show me on Discover", isOn: $draft.isDiscoverable)
                NavigationLink("Discovery Controls") {
                    EditDiscoveryView(draft: $draft)
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
