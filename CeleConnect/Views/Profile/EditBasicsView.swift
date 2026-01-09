//
//  EditBasicsView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//
import SwiftUI

struct EditBasicsView: View {
    @Binding var draft: EditProfileDraft
    @Environment(\.dismiss) private var dismiss

    private let genders = ["Woman", "Man"]
    private let lookingFor = ["Dating", "Friendship", "Long-term"]
    private let religions = ["Celestial", "C&S", "CAC"]

    var body: some View {
        Form {
            Section("Gender") {
                Picker("Gender", selection: $draft.gender) {
                    ForEach(genders, id: \.self) { Text($0) }
                }
            }

            Section("Looking For") {
                Picker("Looking For", selection: $draft.lookingFor) {
                    ForEach(lookingFor, id: \.self) { Text($0) }
                }
            }

            Section("Religion") {
                Picker("Religion", selection: Binding(
                    get: { draft.religion ?? "Prefer not to say" },
                    set: { draft.religion = ($0 == "Prefer not to say") ? nil : $0 }
                )) {
                    Text("Prefer not to say").tag("Prefer not to say")
                    ForEach(religions, id: \.self) { Text($0).tag($0) }
                }
            }
        }
        .navigationTitle("Basics")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { dismiss() } // TODO save
            }
        }
    }
}
