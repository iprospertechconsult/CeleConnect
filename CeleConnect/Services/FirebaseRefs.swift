//
//  FirebaseRefs.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions
import FirebaseFirestore
import UIKit


enum DiscoverError: Error, LocalizedError {
    case notSignedIn
    case noMoreProfiles

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "You must be signed in."
        case .noMoreProfiles: return "No more profiles."
        }
    }
}

final class FirebaseRefs {
    static let shared = FirebaseRefs()
    private init() {}
    
    
    private let db = Firestore.firestore()
    
    // MARK: - Static helpers used across app
    
    static var currentUID: String? {
        Auth.auth().currentUser?.uid
    }
    
    static func user(_ uid: String) -> DocumentReference {
        Firestore.firestore().collection("users").document(uid)
    }
    
    static var users: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    static func matches() -> CollectionReference {
        Firestore.firestore().collection("matches")
    }
    
    private var currentUID: String? {
        Auth.auth().currentUser?.uid
    }
    
    static func match(_ matchId: String) -> DocumentReference {
        Firestore.firestore().collection("matches").document(matchId)
    }
    
    static func messages(matchId: String) -> CollectionReference {
        Firestore.firestore()
            .collection("matches")
            .document(matchId)
            .collection("messages")
    }
    
    // Deterministic match id: minUID_maxUID
    func matchId(uidA: String, uidB: String) -> String {
        let sorted = [uidA, uidB].sorted()
        return "\(sorted[0])_\(sorted[1])"
    }
    
    // MARK: - Discover Feed
    
    /// Fetch a batch of candidates from `users` and filter out those already liked/passed/blocked.
    /// NOTE: Firestore can’t "NOT IN" large sets efficiently; this does client-side filtering after pulling a batch.

    func fetchDiscoverBatch(limit: Int = 30) async throws -> [AppUser] {
        guard let me = currentUID else { throw DiscoverError.notSignedIn }

        // Load my user doc for preferences
        let mySnap = try await db.collection("users").document(me).getDocument()
        guard let my = try? mySnap.data(as: AppUser.self) else { return [] }

        // Pull ids I must exclude
        async let liked = fetchSubcollectionIds(path: "users/\(me)/likesSent")
        async let passed = fetchSubcollectionIds(path: "users/\(me)/passes")
        async let blocked = fetchSubcollectionIds(path: "users/\(me)/blocks")

        let exclude = Set((try await liked) + (try await passed) + (try await blocked) + [me])

        // Base query (index-friendly)
        var q: Query = db.collection("users")
            .whereField("isDiscoverable", isEqualTo: true)
            .limit(to: limit)

        // Optional: gender targeting (AppUser.gender & interestedIn are enums, stored as rawValue)
        // We'll filter client-side to avoid index pain unless you build indexes later.

        let snap = try await q.getDocuments()

        var candidates: [AppUser] = []
        candidates.reserveCapacity(snap.documents.count)

        for doc in snap.documents {
            if exclude.contains(doc.documentID) { continue }

            if let u = try? doc.data(as: AppUser.self) {
                // Skip users who haven't completed onboarding if you want:
                // if !u.didCompleteOnboarding { continue }

                // Client-side filtering examples (adjust to YOUR AppUser fields)
                // 1) Only show people I'm interested in
                if u.gender != my.interestedIn { continue }

                // 2) Reciprocity (they should be interested in my gender)
                if u.interestedIn != my.gender { continue }

                candidates.append(u)
            }
        }

        return candidates
    }

    
    private func fetchSubcollectionIds(path: String) async throws -> [String] {
        let snap = try await db.collection(path).limit(to: 500).getDocuments()
        return snap.documents.map { $0.documentID }
    }
    
    // MARK: - Swipe Writes
    
    func pass(otherUid: String) async throws {
        guard let me = currentUID else { throw DiscoverError.notSignedIn }
        try await db
            .collection("users").document(me)
            .collection("passes").document(otherUid)
            .setData(["createdAt": FieldValue.serverTimestamp()], merge: true)
    }
    
    func fetchCurrentUser() async throws -> AppUser {
        guard let uid = FirebaseRefs.currentUID else {
            throw DiscoverError.notSignedIn
        }

        let snap = try await FirebaseRefs.user(uid).getDocument()

        if let user = try? snap.data(as: AppUser.self) {
            return user
        }

        throw DiscoverError.notSignedIn
    }

    /// Returns matchId if it became a match, else nil.
    func like(otherUid: String) async throws -> String? {
        guard let me = currentUID else { throw DiscoverError.notSignedIn }

        // 1) write my like
        try await db
            .collection("users").document(me)
            .collection("likesSent").document(otherUid)
            .setData(["createdAt": FieldValue.serverTimestamp()], merge: true)

        // 2) check reciprocal like: does other user have likesSent/{me} ?
        let reciprocal = try await db
            .collection("users").document(otherUid)
            .collection("likesSent").document(me)
            .getDocument()

        guard reciprocal.exists else { return nil }

        // 3) create match doc deterministically (idempotent)
        let mId = matchId(uidA: me, uidB: otherUid)
        let matchRef = db.collection("matches").document(mId)

        // Use transaction so we don’t overwrite lastMessage fields unnecessarily
        _ = try await db.runTransaction { txn, errorPointer -> Any? in
            do {
                let snap = try txn.getDocument(matchRef)

                if !snap.exists {
                    txn.setData([
                        "users": [me, otherUid],
                        "createdAt": FieldValue.serverTimestamp(),
                        "lastMessageAt": FieldValue.serverTimestamp(),
                        "lastMessageText": "",
                        "lastMessageFrom": me
                    ], forDocument: matchRef)
                }

                return nil // we don't need a return value
            } catch let err as NSError {
                errorPointer?.pointee = err
                return nil
            }
        }

        return mId
    }

}
extension FirebaseRefs {

    // Storage root helpers
    static var storage: StorageReference {
        Storage.storage().reference()
    }

    /// users/{uid}/photos/{photoId}.jpg
    static func userPhotoRef(uid: String, photoId: String) -> StorageReference {
        storage.child("users").child(uid).child("photos").child("\(photoId).jpg")
    }

    /// Uploads an array of UIImages, returns downloadable URLs in the same order.
    static func uploadUserPhotos(uid: String, images: [UIImage]) async throws -> [String] {
        guard !images.isEmpty else { return [] }

        // compress to jpeg (reasonable size/quality for dating app)
        func jpegData(_ image: UIImage) throws -> Data {
            // Resize slightly if you want; keeping simple here.
            guard let data = image.jpegData(compressionQuality: 0.82) else {
                throw NSError(domain: "PhotoUpload", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not encode image"])
            }
            return data
        }

        var urls: [String] = []
        urls.reserveCapacity(images.count)

        for img in images {
            let photoId = UUID().uuidString
            let ref = userPhotoRef(uid: uid, photoId: photoId)
            let data = try jpegData(img)

            // metadata
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"

            // putData is callback-based; wrap it into async
            _ = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<StorageMetadata, Error>) in
                ref.putData(data, metadata: meta) { metadata, error in
                    if let error { cont.resume(throwing: error); return }
                    cont.resume(returning: metadata ?? StorageMetadata())
                }
            }

            // get download URL
            let url = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<URL, Error>) in
                ref.downloadURL { url, error in
                    if let error { cont.resume(throwing: error); return }
                    guard let url else {
                        cont.resume(throwing: NSError(domain: "PhotoUpload", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing download URL"]))
                        return
                    }
                    cont.resume(returning: url)
                }
            }

            urls.append(url.absoluteString)
        }

        return urls
    }

    /// Uploads photos and saves photoURLs + mainPhotoURL to Firestore user doc.
    /// Main photo defaults to the first image in the provided order.
    static func saveUserPhotos(uid: String, images: [UIImage]) async throws -> (photoURLs: [String], mainPhotoURL: String?) {
        let urls = try await uploadUserPhotos(uid: uid, images: images)
        let main = urls.first

        // Save to Firestore
        try await user(uid).setData([
            "photoURLs": urls,
            "mainPhotoURL": main as Any,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)

        return (urls, main)
    }
}
