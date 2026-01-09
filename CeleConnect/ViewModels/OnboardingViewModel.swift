//
//  OnboardingViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    @Published var didCompleteOnboarding: Bool = false

    func loadState() async {
        // You can read Firestore and set didCompleteOnboarding
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let doc = try? await Firestore.firestore().collection("users").document(uid).getDocument()
        self.didCompleteOnboarding = (doc?.data()?["didCompleteOnboarding"] as? Bool) == true
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
}

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
    var photoLocalItems: [Data] = [] // you’ll store picked images as Data
}
