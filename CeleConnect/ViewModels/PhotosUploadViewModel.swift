//
//  PhotosUploadViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import UIKit
import Combine

@MainActor
final class PhotosUploadViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var errorMessage: String? = nil

    func uploadAndSave(images: [UIImage]) async -> (photoURLs: [String], mainPhotoURL: String?)? {
        guard let uid = FirebaseRefs.currentUID else {
            errorMessage = "Not signed in."
            return nil
        }

        isUploading = true
        errorMessage = nil
        defer { isUploading = false }

        do {
            return try await FirebaseRefs.saveUserPhotos(uid: uid, images: images)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
