//
//  OnboardingProgressBar.swift
//  CeleConnect
//
//  Created by Deborah on 1/14/26.
//

import SwiftUI

struct OnboardingProgressBar: View {
    let progress: Double
    let brand: Color
    var showStepText: Bool = true
    var stepText: String = ""

    var body: some View {
        VStack(spacing: 6) {
            ProgressView(value: progress)
                .tint(brand)

            if showStepText, !stepText.isEmpty {
                Text(stepText)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}
