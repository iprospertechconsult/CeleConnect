//
//  RemoteImage.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct RemoteImage: View {
    let urlString: String?
    var cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            // Background placeholder (always present so sizing is stable)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.gray.opacity(0.15))

            if let urlString,
               let url = URL(string: urlString),
               !urlString.isEmpty {

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.opacity)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    @unknown default:
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .animation(.easeInOut(duration: 0.2), value: urlString ?? "")
    }
}
