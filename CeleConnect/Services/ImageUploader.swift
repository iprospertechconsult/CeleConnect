//
//  ImageUploader.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import UIKit
import FirebaseStorage

enum ImageUploader {
    static func uploadProfileImage(uid: String, image: UIImage) async throws -> String {
        let data = image.jpegData(compressionQuality: 0.85) ?? Data()
        let filename = UUID().uuidString + ".jpg"
        let ref = Storage.storage().reference(withPath: "profileImages/\(uid)/\(filename)")

        _ = try await ref.putDataAsync(data)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
