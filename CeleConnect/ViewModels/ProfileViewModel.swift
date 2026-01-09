//
//  ProfileViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import Combine
import FirebaseFirestore
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Form State (UI-friendly)

    @Published var firstName: String = ""
    @Published var ageText: String = ""          // TextField-friendly
    @Published var aboutMeText: String = ""      // Editable combined AboutMe text

    @Published var images: [UIImage] = []        // For MultiPhotoPicker
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Load existing profile into form

    func loadMeIntoForm() async {
        guard let uid = FirebaseRefs.currentUID else { return }

        do {
            let doc = try await FirebaseRefs.user(uid).getDocument()
            let user = try doc.data(as: AppUser.self)

            firstName = user.firstName
            ageText = user.age > 0 ? "\(user.age)" : ""

            // Collapse AboutMe struct into editable text
            aboutMeText = [
                user.aboutMe?.personality,
                user.aboutMe?.faithJourney,
                user.aboutMe?.values
            ]
            .compactMap { $0 }
            .joined(separator: "\n\n")

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save Profile

    /// Saves profile fields + uploads selected images to Storage and stores URLs in Firestore.
    /// Returns true on success.
    func saveProfile() async -> Bool {
        guard let uid = FirebaseRefs.currentUID else {
            errorMessage = "Not signed in."
            return false
        }

        // MARK: - Validation

        let trimmedName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter your first name."
            return false
        }

        guard let age = Int(ageText), age >= 18 else {
            errorMessage = "Age must be 18+."
            return false
        }

        isSaving = true
        errorMessage = nil

        do {
            // MARK: - Upload Images

            var uploadedURLs: [String] = []

            if !images.isEmpty {
                for img in images {
                    let url = try await ImageUploader.uploadProfileImage(
                        uid: uid,
                        image: img
                    )
                    uploadedURLs.append(url)
                }
            }

            // MARK: - Build AboutMe object (single-text version for now)

            let aboutMe: AboutMe? = {
                let t = aboutMeText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !t.isEmpty else { return nil }

                return AboutMe(
                    personality: t,
                    faithJourney: nil,
                    values: nil
                )
            }()

            // MARK: - Firestore Update (AppUser-compatible)

            var data: [String: Any] = [
                "firstName": trimmedName,
                "age": age,
                "aboutMe": aboutMe as Any,
                "updatedAt": FieldValue.serverTimestamp(),
                "isDiscoverable": true
            ]

            if !uploadedURLs.isEmpty {
                data["photoURLs"] = FieldValue.arrayUnion(uploadedURLs)
                data["mainPhotoURL"] = uploadedURLs.first
            }

            try await FirebaseRefs.user(uid).setData(data, merge: true)

            isSaving = false
            return true

        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
