//
//  ProfileDraft.swift
//  CeleConnect
//

import Foundation

struct ProfileDraft: Equatable, Codable {

    // MARK: - Identity (Display Name)
    var firstName: String = ""
    var isNameLocked: Bool = false   // 🔒 locked after onboarding continue

    // MARK: - Core
    var birthday: Date = Date()
    var gender: String = ""
    var lookingFor: String = ""

    // MARK: - About
    var bio: String = ""
    var city: String = ""
    var religion: String? = nil

    // MARK: - Photos
    var photoURLs: [String] = []
    var mainPhotoURL: String? = nil

    // MARK: - Discovery
    var isDiscoverable: Bool = true
    var minAgePref: Int = 18
    var maxAgePref: Int = 99
    var distanceMilesPref: Int = 25

    // MARK: - Mock (Previews)
    static var mock: ProfileDraft {
        .init(
            firstName: "Deborah",
            isNameLocked: true,
            birthday: Date(),
            gender: "Woman",
            lookingFor: "Dating",
            bio: "Here for something genuine ✨",
            city: "Atlanta",
            religion: nil,
            photoURLs: [],
            mainPhotoURL: nil,
            isDiscoverable: true,
            minAgePref: 24,
            maxAgePref: 35,
            distanceMilesPref: 25
        )
    }
}
