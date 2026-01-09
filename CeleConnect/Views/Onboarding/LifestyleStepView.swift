//
//  LifestyleStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct LifestyleStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    // Christian-friendly + safety-minded. Keep it optional but structured.
    // Stored into vm.draft.lifestyle as key -> value
    private let churchFrequencyOptions = [
        "Every week",
        "2–3x/month",
        "Monthly",
        "Sometimes",
        "Prefer not to say"
    ]

    private let prayerLifeOptions = [
        "Daily",
        "A few times/week",
        "Occasionally",
        "Growing in it",
        "Prefer not to say"
    ]

    private let alcoholOptions = [
        "No",
        "Occasionally",
        "Yes",
        "Prefer not to say"
    ]

    private let smokingOptions = [
        "No",
        "Occasionally",
        "Yes",
        "Prefer not to say"
    ]

    private let sutanaOptions = [
        "Yes (I have one)",
        "Not yet (I’m getting one)",
        "Prefer not to say"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Header
                VStack(spacing: 6) {
                    Text("Lifestyle habits")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Text("This helps us make better matches within a Christ-centered community.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 6)

                // Sections
                LifestyleSection(
                    title: "Church attendance",
                    subtitle: "How often do you attend church?",
                    selection: binding(for: "churchAttendance", default: ""),
                    options: churchFrequencyOptions
                )

                LifestyleSection(
                    title: "Prayer life",
                    subtitle: "How would you describe your prayer life?",
                    selection: binding(for: "prayerLife", default: ""),
                    options: prayerLifeOptions
                )

                LifestyleSection(
                    title: "Alcohol",
                    subtitle: "Do you drink alcohol?",
                    selection: binding(for: "alcohol", default: "No"),
                    options: alcoholOptions
                )

                LifestyleSection(
                    title: "Smoking",
                    subtitle: "Do you smoke?",
                    selection: binding(for: "smoking", default: "No"),
                    options: smokingOptions
                )

                LifestyleSection(
                    title: "Sutana (white garment)",
                    subtitle: "Do you have your sutana for profile photos?",
                    selection: binding(for: "sutana", default: ""),
                    options: sutanaOptions
                )

                // Optional note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Anything else?")
                        .font(.headline)
                        .foregroundStyle(.white)

                    TextField(
                        "Optional (e.g., “Worship team”, “Youth ministry”, “Fasting Fridays”)",
                        text: binding(for: "extra", default: "")
                    )
                    .textFieldStyle(.roundedBorder)
                }
                .padding(.top, 4)

                // Continue
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
                .padding(.top, 10)

                Spacer(minLength: 24)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            // Seed defaults if you want (optional)
            if vm.draft.lifestyle["alcohol"] == nil { vm.draft.lifestyle["alcohol"] = "No" }
            if vm.draft.lifestyle["smoking"] == nil { vm.draft.lifestyle["smoking"] = "No" }
        }
    }

    // MARK: - Helpers

    private func binding(for key: String, default defaultValue: String) -> Binding<String> {
        Binding(
            get: { vm.draft.lifestyle[key] ?? defaultValue },
            set: { vm.draft.lifestyle[key] = $0 }
        )
    }
}

private struct LifestyleSection: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { opt in
                    ChoiceRow(
                        title: opt,
                        selected: selection == opt
                    ) {
                        selection = opt
                    }
                }
            }
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(18)
    }
}
