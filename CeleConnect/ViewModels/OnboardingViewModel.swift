//
//  OnboardingViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    enum Step: Int, CaseIterable {
        case firstName
        case birthday
        case gender
        case distance
        case lookingFor
        case lifestyle
        case aboutYou
        case interests
        case photos
        case location
        case notifications
        case tutorial
    }

    @Published var step: Step = .firstName
    @Published var draft = UserProfileDraft()

    // ✅ These belong to the ViewModel (not the Draft)
    @Published var didCompleteOnboarding: Bool = false
    @Published var locationCity: String = ""
    @Published var allowWorldwide: Bool = true
    @Published var notificationsEnabled: Bool = false

    func loadState() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        do {
            let doc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            let data = doc.data() ?? [:]

            self.didCompleteOnboarding = (data["didCompleteOnboarding"] as? Bool) == true
            self.locationCity = data["locationCity"] as? String ?? ""
            self.allowWorldwide = data["allowWorldwide"] as? Bool ?? true
            self.notificationsEnabled = data["notificationsEnabled"] as? Bool ?? false

        } catch {
            // optional: handle error
            print("loadState error: \(error.localizedDescription)")
        }
    }

    func next() {
        guard let idx = Step.allCases.firstIndex(of: step) else { return }
        let nextIdx = Step.allCases.index(after: idx)
        if nextIdx < Step.allCases.endIndex {
            step = Step.allCases[nextIdx]
        }
    }

    func back() {
        guard let idx = Step.allCases.firstIndex(of: step), idx > 0 else { return }
        step = Step.allCases[Step.allCases.index(before: idx)]
    }

    // ✅ MOVE finishOnboarding HERE
    func finishOnboarding() {
        didCompleteOnboarding = true

        // Save locally so onboarding never shows again
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Save remotely (non-blocking)
        Task {
            guard let uid = Auth.auth().currentUser?.uid else { return }

            try? await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData([
                    "didCompleteOnboarding": true,
                    "locationCity": locationCity,
                    "allowWorldwide": allowWorldwide,
                    "notificationsEnabled": notificationsEnabled,

                    // Optional: also persist draft fields you care about:
                    "firstName": draft.firstName,
                    "birthday": draft.birthdayISO,
                    "gender": draft.gender,
                    "interestedIn": draft.interestedIn,
                    "distanceMiles": draft.distanceMiles,
                    "lookingFor": draft.lookingFor,
                    "interests": draft.interests,
                    "photoURLs": draft.photoURLs,
                    "mainPhotoURL": draft.mainPhotoURL
                ], merge: true)
        }
    }
}

// MARK: - Draft (data only)
struct UserProfileDraft {
    var firstName: String = ""
    var birthday: Date = Calendar.current.date(byAdding: .year, value: -22, to: Date()) ?? Date()

    var gender: String = ""          // "male" | "female"
    var interestedIn: String = ""    // auto

    var distanceMiles: Int = 0       // 0 => Anywhere
    var lookingFor: String = ""

    var lifestyle: [String: String] = [:]
    var about: [String: String] = [:]

    var interests: [String] = []

    // You can store picked images as Data, or switch to PhotosPickerItem
    var photoLocalItems: [Data] = []
    var photoURLs: [String] = []
    var mainPhotoURL: String = ""

    // helper for Firestore saving
    var birthdayISO: String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: birthday)
    }
}
