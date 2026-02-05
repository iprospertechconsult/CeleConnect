//
//  EnjoyDoingComponents.swift
//  CeleConnect
//
//  Created by Deborah on 1/14/26.
//

import SwiftUI

// MARK: - Wrap layout (Flow) — prevents overlap + wraps like tags

struct WrapLayout: Layout {
    var hSpacing: CGFloat = 10
    var vSpacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        guard maxWidth > 0 else {
            // fallback: stack vertically if width unknown
            var height: CGFloat = 0
            var width: CGFloat = 0
            for s in subviews {
                let size = s.sizeThatFits(.unspecified)
                width = max(width, size.width)
                height += size.height + vSpacing
            }
            return CGSize(width: width, height: max(0, height - vSpacing))
        }

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for s in subviews {
            let size = s.sizeThatFits(.unspecified)

            if x + size.width > maxWidth, x > 0 {
                // new row
                x = 0
                y += rowHeight + vSpacing
                rowHeight = 0
            }

            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }

        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for s in subviews {
            let size = s.sizeThatFits(.unspecified)

            if x + size.width > bounds.minX + maxWidth, x > bounds.minX {
                // new row
                x = bounds.minX
                y += rowHeight + vSpacing
                rowHeight = 0
            }

            s.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + hSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Selected pill (top)

struct SelectedPill: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: 8) {
                Text(title).bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                Image(systemName: "xmark")
                    .font(.caption).bold()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.white.opacity(0.14))
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Interest chip (keep your original opacity style)

struct InterestChip: View {
    let title: String
    let selected: Bool
    let brand: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline).bold()
                .foregroundStyle(selected ? .white : .white.opacity(0.9))
                .lineLimit(1)                 // ✅ one line only
                .truncationMode(.tail)        // ✅ never wrap, never overflow
                .minimumScaleFactor(0.9)      // ✅ squeeze slightly before truncating
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: 260, alignment: .center) // ✅ hard cap prevents off-screen chips
                .background(selected ? brand : .white.opacity(0.10))
                .overlay(
                    Capsule().stroke(.white.opacity(0.18), lineWidth: selected ? 0 : 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section (wrap chips like tags)

struct EnjoySection: View {
    let icon: String
    let title: String
    let options: [String]
    let brand: Color
    let isSelected: (String) -> Bool
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(icon).font(.title3)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            WrapLayout(hSpacing: 10, vSpacing: 10) {
                ForEach(options.indices, id: \.self) { i in
                    let opt = options[i]
                    InterestChip(
                        title: opt,
                        selected: isSelected(opt),
                        brand: brand
                    ) {
                        onToggle(opt)
                    }
                }
            }
        }
        .padding()
        .background(.white.opacity(0.08))
        .cornerRadius(18)
    }
}

// MARK: - Bottom scroll hint helper

struct BottomOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
