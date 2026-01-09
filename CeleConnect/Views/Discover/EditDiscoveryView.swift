//
//  EditDiscoveryView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

struct EditDiscoveryView: View {
    @Binding var draft: EditProfileDraft
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Visibility") {
                Toggle("Discoverable", isOn: $draft.isDiscoverable)
            }

            Section("Preferences") {
                Stepper("Min Age: \(draft.minAgePref)", value: $draft.minAgePref, in: 18...99)
                Stepper("Max Age: \(draft.maxAgePref)", value: $draft.maxAgePref, in: 18...99)
                Stepper("Distance: \(draft.distanceMilesPref) mi", value: $draft.distanceMilesPref, in: 1...200)
            }
        }
        .navigationTitle("Discovery")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") { dismiss() } // TODO save
            }
        }
        .onChange(of: draft.minAgePref) { _, _ in
            if draft.minAgePref > draft.maxAgePref { draft.maxAgePref = draft.minAgePref }
        }
    }
}
