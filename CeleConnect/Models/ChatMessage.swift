//
//  ChatMessage.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var fromUid: String
    var text: String
    var createdAt: Timestamp?
}
