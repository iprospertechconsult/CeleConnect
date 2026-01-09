//
//  ProfileSetupView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct MultiPhotoPicker: View {
    // Option A: binding (ProfileSetupView)
    private var imagesBinding: Binding<[UIImage]>?

    // Option B: callback (Onboarding PhotosStepView)
    private var onPick: (([UIImage]) -> Void)?

    private let selectionLimit: Int

    @State private var selectedItems: [PhotosPickerItem] = []

    // ✅ Init for ProfileSetupView: MultiPhotoPicker(images: $vm.images)
    init(images: Binding<[UIImage]>, selectionLimit: Int = 6) {
        self.imagesBinding = images
        self.onPick = nil
        self.selectionLimit = selectionLimit
    }

    // ✅ Init for Onboarding: MultiPhotoPicker(selectionLimit: 6, onPick: { ... })
    init(selectionLimit: Int = 6, onPick: @escaping ([UIImage]) -> Void) {
        self.imagesBinding = nil
        self.onPick = onPick
        self.selectionLimit = selectionLimit
    }

    var body: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: selectionLimit,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Text("Add Photos")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.10))
                .cornerRadius(12)
                .foregroundStyle(.white)
        }
        .onChange(of: selectedItems) { _, newItems in
            Task {
                var picked: [UIImage] = []
                picked.reserveCapacity(newItems.count)

                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        picked.append(img)
                    }
                }

                if let imagesBinding {
                    // Binding mode: append and cap
                    let combined = imagesBinding.wrappedValue + picked
                    imagesBinding.wrappedValue = Array(combined.prefix(selectionLimit))
                } else {
                    // Callback mode
                    onPick?(picked)
                }

                selectedItems = []
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
    }
}
