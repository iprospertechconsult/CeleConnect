//
//  PhotosStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//
//  Signup step: Upload 2+ photos (Sutana required), upload to Firebase Storage,
//  save photoURLs + mainPhotoURL into Firestore users/{uid}, then continue.
//

import SwiftUI
import PhotosUI
import UIKit
import Combine

struct PhotosStepView: View {

    // Parent controls
    var onBack: (() -> Void)? = nil
    /// Called AFTER upload succeeds + Firestore is updated.
    /// Returns (photoURLs, mainPhotoURL)
    var onNext: (_ photoURLs: [String], _ mainPhotoURL: String?) -> Void

    // Brand
    private let brand = Color(hex: "#8B1E3F")

    // Local picker state
    @State private var images: [UIImage] = []
    @State private var showPicker = false
    @State private var localError: String?

    // Upload state
    @StateObject private var uploadVM = PhotosUploadViewModel()

    private var isValid: Bool { images.count >= 2 }

    var body: some View {
        ZStack {
            LinearGradient(colors: [brand, .black],
                           startPoint: .top,
                           endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                sutanaNotice

                grid

                // Validation error
                if let localError {
                    Text(localError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Upload error
                if let msg = uploadVM.errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer(minLength: 0)

                buttons
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .sheet(isPresented: $showPicker) {
            MultiPhotoPicker(
                selectionLimit: 6,
                onPick: { picked in
                    let merged = (images + picked)
                    images = Array(merged.prefix(6))
                    localError = nil
                    uploadVM.errorMessage = nil
                }
            )
        }

        .overlay {
            if uploadVM.isUploading {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Uploading your photos…")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(18)
                    .background(.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }

    // MARK: - UI Pieces

    private var header: some View {
        VStack(spacing: 6) {
            HStack {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .contentShape(Rectangle())
                }

                Spacer()

                Text("Recent Pics")
                    .font(.title2).bold()
                    .foregroundStyle(.white)

                Spacer()

                // balance back button width
                Color.clear.frame(width: 44, height: 44)
            }

            Text("Add at least **2 photos** (Sutana required). Your first photo will be your main photo.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Text("\(images.count)/6")
                    .font(.caption).bold()
                    .foregroundStyle(.white)

                ProgressView(value: Double(images.count), total: 6)
                    .tint(.white.opacity(0.85))
                    .frame(maxWidth: 180)

                Text(isValid ? "✅ Ready" : "2+ required")
                    .font(.caption).bold()
                    .foregroundStyle(isValid ? .green : .white.opacity(0.75))
            }
            .padding(.top, 6)
        }
    }

    private var sutanaNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sutana-only photos")
                    .font(.subheadline).bold()
                    .foregroundStyle(.white)

                Text("For community safety and consistency, please upload photos wearing your white garment (Sutana).")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()
        }
        .padding(14)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var grid: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Photos")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    showPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text(images.isEmpty ? "Add Photos" : "Add More")
                    }
                    .font(.subheadline).bold()
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .contentShape(Rectangle())
                .disabled(uploadVM.isUploading)
            }

            if images.isEmpty {
                emptyState
            } else {
                photoGrid
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 34))
                .foregroundStyle(.white.opacity(0.85))

            Text("No photos yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Tap **Add Photos** to upload at least 2.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var photoGrid: some View {
        let cols = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                PhotoTile(
                    image: img,
                    isMain: idx == 0,
                    onMakeMain: { makeMain(at: idx) },
                    onRemove: { remove(at: idx) }
                )
            }
        }
        .padding(12)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var buttons: some View {
        VStack(spacing: 10) {
            Button {
                localError = nil
                uploadVM.errorMessage = nil

                guard isValid else {
                    localError = "Please upload at least 2 photos to continue."
                    return
                }

                Task {
                    if let result = await uploadVM.uploadAndSave(images: images) {
                        onNext(result.photoURLs, result.mainPhotoURL)
                    }
                }
            } label: {
                Text(uploadVM.isUploading ? "Uploading..." : "Continue")
                    .font(.headline).bold()
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isValid ? brand : .white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!isValid || uploadVM.isUploading)
            .contentShape(Rectangle())

            Text("You can edit your photos later in Profile.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
        }
    }

    // MARK: - Actions

    private func makeMain(at index: Int) {
        guard images.indices.contains(index), index != 0 else { return }
        let chosen = images.remove(at: index)
        images.insert(chosen, at: 0)
    }

    private func remove(at index: Int) {
        guard images.indices.contains(index) else { return }
        images.remove(at: index)
        localError = nil
        uploadVM.errorMessage = nil
    }
}

// MARK: - Tile UI

private struct PhotoTile: View {
    let image: UIImage
    let isMain: Bool
    let onMakeMain: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 108)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .trailing, spacing: 6) {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.caption).bold()
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.55))
                        .clipShape(Circle())
                }
                .contentShape(Rectangle())

                if !isMain {
                    Button(action: onMakeMain) {
                        Text("Set Main")
                            .font(.caption2).bold()
                            .foregroundStyle(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(.black.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .contentShape(Rectangle())
                }
            }
            .padding(6)

            if isMain {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                    Text("Main")
                }
                .font(.caption2).bold()
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.black.opacity(0.60))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }
}
