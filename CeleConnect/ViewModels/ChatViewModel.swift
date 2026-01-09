//
//  ChatViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var draft: String = ""
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    func listen(matchId: String) {
        listener?.remove()
        listener = FirebaseRefs.messages(matchId: matchId)
            .order(by: "createdAt", descending: false)
            .limit(to: 200)
            .addSnapshotListener { [weak self] snap, err in
                if let err { self?.errorMessage = err.localizedDescription; return }
                self?.messages = snap?.documents.compactMap { try? $0.data(as: ChatMessage.self) } ?? []
            }
    }

    func send(matchId: String) async {
        guard let me = FirebaseRefs.currentUID else { return }
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""

        do {
            let now = FieldValue.serverTimestamp()
            let msgRef = FirebaseRefs.messages(matchId: matchId).document()

            try await msgRef.setData([
                "fromUid": me,
                "text": text,
                "createdAt": now
            ])

            try await FirebaseRefs.match(matchId).setData([
                "lastMessageAt": now,
                "lastMessageText": text,
                "lastMessageFrom": me
            ], merge: true)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit { listener?.remove() }
}
