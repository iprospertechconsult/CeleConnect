//
//  AboutYouStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct AboutYouStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    private let brand = Color(hex: "#a9054b")

    // Christian-friendly prompts (kept respectful + optional)
    private let faithStageOptions = [
        "Strong in faith",
        "Growing in faith",
        "New believer",
        "Prefer not to say"
    ]

    private let faithExpressionOptions = [
        "Prayer",
        "Bible study",
        "Worship",
        "Service / ministry",
        "Fellowship",
        "Fasting",
        "Giving",
        "Evangelism"
    ]

    private let valuesOptions = [
        "Integrity",
        "Kindness",
        "Humility",
        "Patience",
        "Accountability",
        "Family-oriented",
        "Purpose-driven",
        "Peaceful home",
        "Communication",
        "Financial stewardship"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Header
                VStack(spacing: 6) {
                    Text("What else makes you… you?")
                        .font(.title2).bold()
                        .foregroundStyle(.white)

                    Text("Share what matters most so we can match you better.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 6)

                // Bio
                VStack(alignment: .leading, spacing: 8) {
                    Text("Short bio")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Keep it simple. Be kind. Be you.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))

                    TextEditor(text: bindingAbout("bio", default: ""))
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(.white.opacity(0.08))
                        .cornerRadius(14)
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                }

                // Faith stage
                CardSection(title: "Faith journey", subtitle: "How would you describe your faith right now?") {
                    ForEach(faithStageOptions, id: \.self) { opt in
                        ChoiceRow(title: opt, selected: bindingAbout("faithStage", default: "") .wrappedValue == opt) {
                            vm.draft.about["faithStage"] = opt
                        }
                    }
                }

                // Faith expression (multi-select)
                CardSection(title: "Faith expression", subtitle: "What helps you stay connected spiritually? (Select all that apply)") {
                    MultiSelectChips(
                        options: faithExpressionOptions,
                        selected: bindingArrayAbout("faithExpression")
                    )
                }

                // Core values (multi-select)
                CardSection(title: "Core values", subtitle: "What values matter most in your life and relationships?") {
                    MultiSelectChips(
                        options: valuesOptions,
                        selected: bindingArrayAbout("values")
                    )
                }

                // Favorite scripture (optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Favorite scripture (optional)")
                        .font(.headline)
                        .foregroundStyle(.white)

                    TextField("e.g., Proverbs 3:5–6", text: bindingAbout("favoriteScripture", default: ""))
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(.white.opacity(0.08))
                .cornerRadius(18)

                // Dealbreakers / boundaries (optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Boundaries (optional)")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Example: “No smoking”, “Church-centered home”, “Intentional dating”.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.7))

                    TextField("Type here…", text: bindingAbout("boundaries", default: ""))
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(.white.opacity(0.08))
                .cornerRadius(18)

                // Continue
                Button {
                    // If you want: require at least a short bio, but keeping optional is friendlier.
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
    }

    // MARK: - Helpers

    private func bindingAbout(_ key: String, default defaultValue: String) -> Binding<String> {
        Binding(
            get: { vm.draft.about[key] ?? defaultValue },
            set: { vm.draft.about[key] = $0 }
        )
    }

    /// Stores multi-select arrays as a comma-separated string under the hood:
    /// about["values"] = "Integrity,Kindness,Humility"
    private func bindingArrayAbout(_ key: String) -> Binding<Set<String>> {
        Binding(
            get: {
                let raw = vm.draft.about[key] ?? ""
                let parts = raw
                    .split(separator: ",")
                    .map { String($0) }
                    .filter { !$0.isEmpty }
                return Set(parts)
            },
            set: { newSet in
                let joined = newSet.sorted().joined(separator: ",")
                vm.draft.about[key] = joined
            }
        )
    }
}

// MARK: - UI Components

private struct CardSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))

            content
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(18)
    }
}

private struct MultiSelectChips: View {
    let options: [String]
    @Binding var selected: Set<String>

    var body: some View {
        // Simple wrap layout using adaptive grid
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
            ForEach(options, id: \.self) { opt in
                let isOn = selected.contains(opt)
                Button {
                    if isOn { selected.remove(opt) } else { selected.insert(opt) }
                } label: {
                    HStack(spacing: 8) {
                        Text(opt)
                            .font(.subheadline).bold()
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
