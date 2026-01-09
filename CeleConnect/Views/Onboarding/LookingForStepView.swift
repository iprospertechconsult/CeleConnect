//
//  LookingForStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct LookingForStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    private let options: [String] = [
        "Long term",
        "Friendship",
        "Dating"
    ]

    var body: some View {
        VStack(spacing: 14) {
            // Header
            VStack(spacing: 6) {
                Text("What are you looking for?")
                    .font(.title2).bold()
                    .foregroundStyle(.white)

                Text("Choose what best fits your intention right now.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
            }
            .padding(.top, 6)

            // Options
            VStack(spacing: 10) {
                ForEach(options, id: \.self) { opt in
                    ChoiceRow(
                        title: opt,
                        selected: vm.draft.lookingFor == opt
                    ) {
                        vm.draft.lookingFor = opt
                    }
                }
            }
            .padding(.top, 6)

            // Continue
            Button {
                guard !vm.draft.lookingFor.isEmpty else { return }
                vm.next()
            } label: {
                Text("Continue").bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.draft.lookingFor.isEmpty ? .white.opacity(0.12) : brand)
                    .cornerRadius(18)
                    .foregroundStyle(.white)
            }
            .disabled(vm.draft.lookingFor.isEmpty)
            .padding(.top, 10)

            Spacer()
        }
        .padding()
    }
}
