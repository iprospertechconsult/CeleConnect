//
//  InterestsStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct InterestsStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    // Christian-friendly + normal lifestyle interests
    private let interestOptions: [String] = [
        "Worship",
        "Bible study",
        "Prayer",
        "Church events",
        "Choir / Music",
        "Youth ministry",
        "Serving / Volunteering",
        "Missions",
        "Christian podcasts",
        "Reading",
        "Fitness",
        "Travel",
        "Cooking",
        "Movies",
        "Entrepreneurship",
        "Tech",
        "Sports",
        "Nature",
        "Family time"
    ]

    private let minRequired = 3

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Header
                VStack(spacing: 6) {
                    Text("What are you into?")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Text("Pick at least \(minRequired). This helps us find better matches.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 6)

                // Selected count
                HStack {
                    Text("\(vm.draft.interests.count) selected")
                        .font(.footnote).bold()
                        .foregroundStyle(vm.draft.interests.count >= minRequired ? .green : .white.opacity(0.75))
                    Spacer()
                    Button("Clear") {
                        vm.draft.interests.removeAll()
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .disabled(vm.draft.interests.isEmpty)
                }
                .padding(.horizontal, 4)

                // Chips
                InterestsChipsGrid(
                    options: interestOptions,
                    selected: Binding(
                        get: { Set(vm.draft.interests) },
                        set: { vm.draft.interests = Array($0).sorted() }
                    )
                )
                .padding(.top, 6)

                // Continue
                Button {
                    guard vm.draft.interests.count >= minRequired else { return }
                    vm.next()
                } label: {
                    Text("Continue").bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.draft.interests.count >= minRequired ? brand : .white.opacity(0.12))
                        .cornerRadius(18)
                        .foregroundStyle(.white)
                }
                .disabled(vm.draft.interests.count < minRequired)
                .padding(.top, 10)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .background(Color.black.ignoresSafeArea())
    }
}

// MARK: - Chips Grid

private struct InterestsChipsGrid: View {
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 10)], spacing: 10) {
            ForEach(options, id: \.self) { opt in
                let isOn = selected.contains(opt)

                Button {
                    if isOn {
                        selected.remove(opt)
                    } else {
                        selected.insert(opt)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(opt)
                            .font(.subheadline).bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        Spacer(minLength: 0)

                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                            .imageScale(.medium)
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(.white.opacity(isOn ? 0.18 : 0.10))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
