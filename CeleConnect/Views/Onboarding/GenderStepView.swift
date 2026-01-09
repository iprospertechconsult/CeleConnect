//
//  GenderStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct GenderStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    var body: some View {
        VStack(spacing: 14) {
            Text("I am a…")
                .font(.title2).bold()
                .foregroundStyle(.white)

            ChoiceRow(title: "Male", selected: vm.draft.gender == "male") {
                vm.draft.gender = "male"
                vm.draft.interestedIn = "female" // auto
            }
            ChoiceRow(title: "Female", selected: vm.draft.gender == "female") {
                vm.draft.gender = "female"
                vm.draft.interestedIn = "male" // auto
            }

            if !vm.draft.gender.isEmpty {
                Text("You’ll be shown: \(vm.draft.interestedIn.capitalized)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 4)
            }

            Button {
                guard !vm.draft.gender.isEmpty else { return }
                vm.next()
            } label: {
                Text("Continue").bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brand)
                    .cornerRadius(18)
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding()
    }
}

struct ChoiceRow: View {
    let title: String
    let selected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title).bold()
                Spacer()
                if selected { Image(systemName: "checkmark.circle.fill") }
            }
            .foregroundStyle(.white)
            .padding()
            .background(.white.opacity(selected ? 0.18 : 0.10))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
