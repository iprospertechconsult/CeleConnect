//
//  MatchesListView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct MatchesListView: View {
    @StateObject private var vm = MatchesViewModel()

    var body: some View {
        NavigationStack {
            List(vm.matches) { match in
                // Safely unwrap match id (DocumentID is String?)
                let matchId = match.id ?? "Unknown"

                NavigationLink {
                    ChatView(match: match)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: "Match: \(matchId)")   // ✅ avoids localization interpolation warning
                            .font(.headline)

                        Text(match.lastMessageText ?? "")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .navigationTitle("Matches")
            .onAppear { vm.startListening() }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { _ in vm.errorMessage = nil }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "")
            }
        }
    }
}
#Preview {
    NavigationStack {
        MatchesListView()
    }
}
