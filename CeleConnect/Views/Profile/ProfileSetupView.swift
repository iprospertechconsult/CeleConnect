//
//  ProfileSetupView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct ProfileSetupView: View {
    @StateObject private var vm = ProfileViewModel()
    var onFinished: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {

                    TextField("Name", text: $vm.displayName)
                        .textFieldStyle(.roundedBorder)

                    TextField("Age (18+)", text: $vm.ageText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)

                    TextField("Bio", text: $vm.bio, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)

                    MultiPhotoPicker(images: $vm.images)

                    if !vm.images.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(vm.images.enumerated()), id: \.offset) { _, img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 120)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    if let msg = vm.errorMessage {
                        Text(msg)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }

                    Button {
                        Task {
                            let ok = await vm.saveProfile()
                            if ok { onFinished() }
                        }
                    } label: {
                        if vm.isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Save Profile")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(12)
                    .disabled(vm.isSaving)
                }
                .padding()
            }
            .navigationTitle("Create Profile")
            .task {
                await vm.loadMeIntoForm()
            }
        }
    }
}
#Preview {
    NavigationStack {
        ProfileSetupView(onFinished: {})
    }
}
