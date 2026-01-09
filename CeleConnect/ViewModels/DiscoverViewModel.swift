//
//  DiscoverViewModel.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var deck: [AppUser] = []
    @Published var showMatchOverlay: Bool = false
    @Published var matchedName: String = ""
    @Published var matchedId: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service = FirebaseRefs.shared
    private var isRefreshing = false

    func loadIfNeeded() async {
        if deck.isEmpty {
            await refresh()
        }
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        isLoading = true
        errorMessage = nil

        do {
            let batch = try await service.fetchDiscoverBatch(limit: 40)
            deck = batch
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func swipeLeft() {
        guard !deck.isEmpty else { return }
        let top = deck.removeFirst()

        Task {
            do {
                try await service.pass(otherUid: top.uid)
            } catch {
                self.errorMessage = error.localizedDescription
            }

            if self.deck.count < 3 {
                await self.refresh()
            }
        }
    }

    func swipeRight() {
        guard !deck.isEmpty else { return }
        let top = deck.removeFirst()

        Task {
            do {
                if let matchId = try await service.like(otherUid: top.uid) {
                    self.matchedName = top.firstName
                    self.matchedId = matchId
                    self.showMatchOverlay = true
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }

            if self.deck.count < 3 {
                await self.refresh()
            }
        }
    }

    func closeMatch() {
        showMatchOverlay = false
        matchedName = ""
        matchedId = ""
    }
}

