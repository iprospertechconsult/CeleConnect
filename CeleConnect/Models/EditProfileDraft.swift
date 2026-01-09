//
//  EditProfileDraft.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import Foundation   // ✅ correct import for a model


struct EditProfileDraft: Equatable {
    var firstName: String
    var bio: String
    var city: String
    var gender: String
    var lookingFor: String
    var religion: String?
    var photoURLs: [String]
    var isDiscoverable: Bool
    var minAgePref: Int
    var maxAgePref: Int
    var distanceMilesPref: Int

    static var mock: EditProfileDraft {
        .init(
            firstName: "Deborah",
            bio: "Here for something genuine ✨",
            city: "Atlanta",
            gender: "Woman",
            lookingFor: "Dating",
            religion: nil,
            photoURLs: [],
            isDiscoverable: true,
            minAgePref: 24,
            maxAgePref: 35,
            distanceMilesPref: 25
        )
    }
}
