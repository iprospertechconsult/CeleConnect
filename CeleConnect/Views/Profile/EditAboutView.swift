//
//  EditAboutView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//
import SwiftUI

struct EditAboutView: View {
    @Binding var draft: EditProfileDraft
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Name") {
                TextField("Display name", text: $draft.firstName)
                    .textInputAutocapitalization(.words)
            }

            Section("City") {
                TextField("City", text: $draft.city)
                    .textInputAutocapitalization(.words)
            }

            Section("Bio") {
                TextEditor(text: $draft.bio)
                    .frame(minHeight: 120)
                Text("\(draft.bio.count)/300")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    // TODO: call your save function / VM
                    dismiss()
                }
                .disabled(draft.firstName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onChange(of: draft.bio) { _, newValue in
            if newValue.count > 300 { draft.bio = String(newValue.prefix(300)) }
        }
    }
}
