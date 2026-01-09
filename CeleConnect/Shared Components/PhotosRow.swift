//
//  PhotosRow.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//
import SwiftUI

struct PhotosRow: View {
    let urls: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(urls.prefix(6), id: \.self) { u in
                    PhotoThumb(urlString: u)
                }
                if urls.isEmpty {
                    Text("Add photos")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                }
            }
            .padding(.vertical, 6)
        }
    }
}

struct PhotoThumb: View {
    let urlString: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.08))
                .frame(width: 68, height: 68)

            if let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Image(systemName: "photo").foregroundStyle(.secondary)
                    }
                }
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Image(systemName: "photo").foregroundStyle(.secondary)
            }
        }
    }
}

struct EditPhotosView: View {
    @Binding var draft: EditProfileDraft

    var body: some View {
        VStack(spacing: 14) {
            Text("Photos Editor")
                .font(.title3).bold()

            Text("Next: add image picker + upload to Storage + update photoURLs/mainPhotoURL")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationTitle("Photos")
    }
}
