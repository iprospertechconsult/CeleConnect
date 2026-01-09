//
//  MatchesViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Combine
import FirebaseFirestore

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published var matches: [Match] = []
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?

    func startListening() {
        guard let me = FirebaseRefs.currentUID else { return }

        listener?.remove()
        listener = FirebaseRefs.matches()
            .whereField("users", arrayContains: me)
            .order(by: "lastMessageAt", descending: true)
            .addSnapshotListener { [weak self] (snap: QuerySnapshot?, err: Error?) in  
                if let err { self?.errorMessage = err.localizedDescription; return }
                guard let docs = snap?.documents else { return }
                self?.matches = docs.compactMap { try? $0.data(as: Match.self) }
            }
    }

    deinit { listener?.remove() }
}
