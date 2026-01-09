//
//  BirthdayStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct BirthdayStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    var body: some View {
        VStack(spacing: 16) {
            Text("Your birthday")
                .font(.title2).bold()
                .foregroundStyle(.white)

            DatePicker(
                "Birthday",
                selection: $vm.draft.birthday,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)

            Button {
                vm.next()
            } label: {
                Text("Continue").bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brand)
                    .cornerRadius(18)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
    }
}
