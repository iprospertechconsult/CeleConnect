//
//  LocationEditView.swift
//  CeleConnect
//
//  Created by Deborah on 1/27/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: ProfileDraft

    /// ✅ persist immediately (Firestore)
    var onSaveNow: ((ProfileDraft) async -> Void)? = nil

    @StateObject private var locationManager = LocationManager()
    @StateObject private var search = LocationSearchService()

    @State private var text: String = ""
    @State private var debounceTask: Task<Void, Never>? = nil

    private let brand = Color(hex: "#a9054b")

    var body: some View {
        ZStack {
            Color(hex: "#F6F6F7").ignoresSafeArea()

            VStack(spacing: 14) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Current location")
                        .font(.footnote)
                        .foregroundStyle(.gray)

                    Text(currentDisplay.isEmpty ? "Not set" : currentDisplay)
                        .font(.headline)
                        .foregroundStyle(.black.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Button {
                    locationManager.requestLocation()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                        Text("Use My Current Location")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(brand)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Search city")
                        .font(.footnote)
                        .foregroundStyle(.gray)

                    TextField("City, State or Country", text: $text)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.08))
                        )
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .onSubmit {
                            Task { await search.validateFreeText(text) }
                        }

                    if search.isResolving {
                        HStack(spacing: 10) {
                            ProgressView().tint(.gray)
                            Text("Validating location…")
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        .padding(.top, 4)
                    }

                    if !search.suggestions.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(search.suggestions, id: \.self) { item in
                                Button {
                                    Task {
                                        await search.resolve(completion: item)
                                        await applyResolvedAndSaveIfPossible()
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .foregroundStyle(.black.opacity(0.85))
                                            .font(.subheadline.weight(.semibold))
                                        if !item.subtitle.isEmpty {
                                            Text(item.subtitle)
                                                .foregroundStyle(.gray)
                                                .font(.footnote)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                }
                                .buttonStyle(.plain)

                                Divider().overlay(Color.black.opacity(0.06))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.08))
                        )
                    }

                    if let err = search.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.red.opacity(0.9))
                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .navigationTitle("Edit Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    Task {
                        await onSaveNow?(draft)   // ✅ persist immediately
                        dismiss()
                    }
                }
                .font(.headline)
            }
        }
        .onAppear {
            if text.isEmpty { text = currentDisplay }
            search.query = text
        }
        .onChange(of: locationManager.city) { _, newValue in
            let city = (newValue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !city.isEmpty else { return }
            text = city
            search.query = city
            search.resolvedDisplay = city
            Task { await applyResolvedAndSaveIfPossible() }
        }
        .onChange(of: text) { _, newValue in
            search.query = newValue
            search.resolvedDisplay = nil

            debounceTask?.cancel()
            debounceTask = Task { [newValue] in
                try? await Task.sleep(nanoseconds: 650_000_000)
                guard !Task.isCancelled else { return }

                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed.count >= 3 else { return }

                if search.suggestions.isEmpty {
                    await search.validateFreeText(trimmed)
                    await applyResolvedAndSaveIfPossible()
                }
            }
        }
    }

    private var currentDisplay: String {
        draft.locationDisplay
    }

    private func applyResolvedAndSaveIfPossible() async {
        let raw = (search.resolvedDisplay ?? text).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }

        let parts = raw
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        draft.city = parts.first ?? ""
        draft.state = parts.indices.contains(1) ? parts[1] : ""
        draft.country = parts.indices.contains(2) ? parts[2] : ""

        await onSaveNow?(draft) // ✅ save instantly when resolved
    }
}
