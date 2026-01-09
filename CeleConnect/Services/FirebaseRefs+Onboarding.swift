//
//  FirebaseRefs+Onboarding.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

extension FirebaseRefs {

    /// Saves onboarding draft into `users/{uid}` (merge) and marks `didCompleteOnboarding = true`.
    @MainActor
    func saveOnboardingProfile(draft: UserProfileDraft) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw DiscoverError.notSignedIn
        }

        let userRef = FirebaseRefs.user(uid)

        // Compute age from birthday
        let age = Calendar.current
            .dateComponents([.year], from: draft.birthday, to: Date())
            .year ?? 0

        // Pull photo URLs (stored as comma-separated earlier)
        let photoURLs: [String] = {
            let raw = draft.about["photoURLs"] ?? ""
            return raw
                .split(separator: ",")
                .map(String.init)
                .filter { !$0.isEmpty }
        }()

        let mainPhotoURL: String? = {
            if let main = draft.about["mainPhotoURL"], !main.isEmpty {
                return main
            }
            return photoURLs.first
        }()

        let payload: [String: Any] = [
            "uid": uid,
            "updatedAt": FieldValue.serverTimestamp(),

            // only set once; safe with merge
            "createdAt": FieldValue.serverTimestamp(),

            // phone auth
            "phoneNumber": Auth.auth().currentUser?.phoneNumber as Any,
            "isPhoneVerified": Auth.auth().currentUser?.phoneNumber != nil,

            // onboarding
            "firstName": draft.firstName,
            "birthday": Timestamp(date: draft.birthday),
            "age": age,

            "gender": draft.gender,
            "interestedIn": draft.interestedIn,
            "distancePrefMiles": draft.distanceMiles,
            "lookingFor": draft.lookingFor,

            "lifestyleHabits": draft.lifestyle,
            "aboutMe": draft.about,
            "interests": draft.interests,

            // photos
            "photoURLs": photoURLs,
            "mainPhotoURL": mainPhotoURL as Any,

            // flags
            "didCompleteOnboarding": true,
            "isDiscoverable": true
        ]

        try await userRef.setData(payload, merge: true)
    }
}
