//
//  Match.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import FirebaseFirestore

struct Match: Identifiable, Codable {
    @DocumentID var id: String?
    var users: [String]
    var createdAt: Timestamp?
    var lastMessageAt: Timestamp?
    var lastMessageText: String?
    var lastMessageFrom: String?
}
