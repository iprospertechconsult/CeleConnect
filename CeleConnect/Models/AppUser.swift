//
//  AppUser.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import FirebaseFirestore

// MARK: - AppUser

struct AppUser: Identifiable, Codable, Equatable {
    
    // MARK: Identity
    var id: String { uid }
    let uid: String
    
    let createdAt: Timestamp?
    let updatedAt: Timestamp?
    
    // MARK: Auth / Security
    let phoneNumber: String?
    let isPhoneVerified: Bool
    
    // MARK: Core Profile
    let firstName: String
    let birthday: String        // ISO string: yyyy-MM-dd
    let age: Int
    
    let gender: Gender
    let interestedIn: Gender
    
    // MARK: Discovery Preferences
    let distancePrefMiles: Int      // 0 = Anywhere
    let lookingFor: LookingFor
    
    // MARK: Personality / Lifestyle
    let lifestyleHabits: LifestyleHabits?
    let aboutMe: AboutMe?
    let interests: [String]
    
    // MARK: Photos
    let photoURLs: [String]
    let mainPhotoURL: String?
    
    // MARK: Location
    let location: UserLocation?
    let city: String?
    let country: String?
    
    // MARK: App State
    let notificationsEnabled: Bool
    let didCompleteOnboarding: Bool
    let isDiscoverable: Bool
    
    // MARK: Firestore Keys
    enum CodingKeys: String, CodingKey {
        case uid
        case createdAt
        case updatedAt
        
        case phoneNumber
        case isPhoneVerified
        
        case firstName
        case birthday
        case age
        
        case gender
        case interestedIn
        
        case distancePrefMiles
        case lookingFor
        
        case lifestyleHabits
        case aboutMe
        case interests
        
        case photoURLs
        case mainPhotoURL
        
        case location
        case city
        case country
        
        case notificationsEnabled
        case didCompleteOnboarding
        case isDiscoverable
    }
    
    //Gender Enum
    enum Gender: String, Codable {
        case male
        case female
    }
    
    //Looking for Enum
    enum LookingFor: String, Codable {
        case longTerm = "Long term"
        case friendship = "Friendship"
        case dating = "Dating"
    }
}
//LocationModel
struct UserLocation: Codable, Equatable {
    let lat: Double
    let lng: Double
}

//Lifestyle(Expandable)

struct LifestyleHabits: Codable, Equatable {
    let drinking: String?
    let smoking: String?
    let churchAttendance: String?
}

//About Me(Expandable)
struct AboutMe: Codable, Equatable {
    let personality: String?
    let faithJourney: String?
    let values: String?
}
