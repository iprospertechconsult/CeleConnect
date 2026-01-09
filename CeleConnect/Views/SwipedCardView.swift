//
//  SwipeCardView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct SwipeCardView: View {
    let user: AppUser
    let onPass: () -> Void
    let onLike: () -> Void

    @State private var offset: CGSize = .zero

    var body: some View {
        VStack(spacing: 10) {

            // Photo
            RemoteImage(urlString: bestPhotoString)
                .frame(height: 420)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text("\(firstNameText), \(user.age)")
                    .font(.title2).bold()

                Text(aboutMeText)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Actions
            HStack(spacing: 14) {
                Button {
                    onPass()
                } label: {
                    Text("Pass")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)

                Button {
                    onLike()
                } label: {
                    Text("Like")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
        .offset(x: offset.width, y: 0)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .gesture(
            DragGesture()
                .onChanged { offset = $0.translation }
                .onEnded { _ in
                    if offset.width > 120 {
                        onLike()
                    } else if offset.width < -120 {
                        onPass()
                    }
                    offset = .zero
                }
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: offset)
    }

    // MARK: - Helpers

    /// Prefer mainPhotoURL if present, otherwise first photoURLs, otherwise empty string.
    private var bestPhotoString: String {
        if let main = user.mainPhotoURL, !main.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return main
        }
        return user.photoURLs.first ?? ""
    }

    /// AppUser uses `firstName` in your new model (not `firstName`)
    private var firstNameText: String {
        let name = user.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Member" : name
    }

    /// Your AppUser has `aboutMe` as an optional custom type or optional string.
    /// This safely renders it without Optional(...) warnings.
    private var aboutMeText: String {
        // If AboutMe is a custom type, this prevents Optional(...) debug text and won’t crash.
        if let about = user.aboutMe {
            let s = String(describing: about).trimmingCharacters(in: .whitespacesAndNewlines)
            return s.isEmpty ? "Here for something meaningful." : s
        }
        return "Here for something meaningful."
    }
}
