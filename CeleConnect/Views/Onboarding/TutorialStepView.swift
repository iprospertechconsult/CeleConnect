//
//  TutorialStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct TutorialStepView: View {

    @ObservedObject var vm: OnboardingViewModel

    @State private var page = 0
    private let brand = Color(hex: "#8B1E3F")

    private struct Tip: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let message: String
    }

    private var tips: [Tip] {
        [
            Tip(
                icon: "hand.draw.fill",
                title: "Swipe to Discover",
                message: "Swipe through profiles to find someone you’d like to connect with."
            ),
            Tip(
                icon: "heart.fill",
                title: "Like with Intention",
                message: "If you’re interested, tap Like. When it’s mutual, you’ll match and can chat."
            ),
            Tip(
                icon: "sparkles",
                title: "Keep it Christ-Centered",
                message: "Be respectful. Keep conversations uplifting, honest, and prayerful."
            )
        ]
    }

    var body: some View {
        VStack(spacing: 18) {

            Spacer(minLength: 8)

            // Header
            Text("Quick Tour")
                .font(.title.bold())
                .foregroundStyle(.white)

            Text("Here’s how CeleConnect works.")
                .font(.footnote)
                .foregroundStyle(.gray)

            // Tutorial pages
            TabView(selection: $page) {
                ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                    TutorialCard(
                        brand: brand,
                        icon: tip.icon,
                        title: tip.title,
                        message: tip.message
                    )
                    .padding(.horizontal, 18)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 360)

            // Dots
            HStack(spacing: 8) {
                ForEach(0..<tips.count, id: \.self) { i in
                    Capsule()
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .opacity(i == page ? 1.0 : 0.35)
                        .animation(.easeInOut(duration: 0.2), value: page)
                        .foregroundStyle(brand)
                }
            }
            .padding(.top, 4)

            Spacer()

            // Actions
            VStack(spacing: 12) {

                Button {
                    if page < tips.count - 1 {
                        withAnimation { page += 1 }
                    } else {
                        finish()
                    }
                } label: {
                    Text(page < tips.count - 1 ? "Next" : "Start Discovering")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(brand)
                        .cornerRadius(16)
                }

                Button {
                    finish()
                } label: {
                    Text("Skip")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(16)
                }

            }
            .padding(.horizontal)

        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    private func finish() {
        // Mark onboarding complete (use whatever your VM uses)
        vm.didCompleteOnboarding = true
        vm.finishOnboarding() // ✅ if you have this, great. If not, see notes below.
    }

}

private struct TutorialCard: View {
    let brand: Color
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {

            ZStack {
                Circle()
                    .fill(brand.opacity(0.18))
                    .frame(width: 96, height: 96)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(brand)
            }
            .padding(.top, 24)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .cornerRadius(22)
    }
}
