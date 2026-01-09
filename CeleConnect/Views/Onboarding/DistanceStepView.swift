//
//  DistanceStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct DistanceStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")
    @State private var sliderValue: Double = 500

    var body: some View {
        VStack(spacing: 16) {
            Text("Distance preference")
                .font(.title2).bold()
                .foregroundStyle(.white)

            Text(vm.draft.distanceMiles == 0 ? "Anywhere" : "\(vm.draft.distanceMiles) miles")
                .font(.headline)
                .foregroundStyle(.white)

            Toggle("Anywhere (Worldwide)", isOn: Binding(
                get: { vm.draft.distanceMiles == 0 },
                set: { vm.draft.distanceMiles = $0 ? 0 : Int(sliderValue) }
            ))
            .tint(brand)
            .foregroundStyle(.white)

            if vm.draft.distanceMiles != 0 {
                Slider(value: $sliderValue, in: 5...10000, step: 5) { _ in
                    vm.draft.distanceMiles = Int(sliderValue)
                }
                .tint(brand)

                Text("Explore out-of-state and international options.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }

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
        .onAppear {
            sliderValue = Double(max(vm.draft.distanceMiles, 500))
            if vm.draft.distanceMiles == 0 { /* Anywhere */ }
        }
    }
}
