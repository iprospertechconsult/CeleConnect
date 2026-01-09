//
//  ExploreView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Explore")
                    .font(.title).bold()
                Text("Search, filters, nearby, categories, etc.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle("Explore")
        }
    }
}
