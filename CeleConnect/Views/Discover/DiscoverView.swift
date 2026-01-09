//
//  DiscoverView.swift
//  CeleConnect
//
//  Tinder-style swipe deck with CeleConnect theme
//

import SwiftUI

struct DiscoverView: View {
    @StateObject var vm: DiscoverViewModel
    let onOpenSettings: () -> Void   // ✅ NEW

    @State private var dragOffset: CGSize = .zero
    private let brand = Color(hex: "#8B1E3F")

    init(
        vm: DiscoverViewModel,
        onOpenSettings: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.onOpenSettings = onOpenSettings
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // ✅ Top bar is locked and will NEVER resize
                    TopBar {
                        onOpenSettings()
                    }
                    // ✅ Logo is drawn ABOVE the bar (overlay) so it can be 100pt
                    //    without affecting the bar height or pushing anything down.
                    .overlay(alignment: .top) {
                        GeometryReader { geo in
                            Image("CCDiscoverLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)          // big logo
                                // ⬇️ center logo inside 64pt bar
                                .position(
                                    x: geo.size.width / 2,
                                    y: 32                     // barHeight / 2
                                )
                                .allowsHitTesting(false)
                        }
                        .frame(height: 64)                    // matches TopBar height
                    }

                    ZStack {
                        // Cards
                        if vm.deck.isEmpty {
                            EmptyDiscoverState(onRefresh: {
                                Task { await vm.refresh() }
                            })
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            cardStack(size: geo.size)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

                        // Bottom controls + tabs (always on top)
                        VStack(spacing: 0) {
                            Spacer()

                            ActionBar(
                                brand: brand,
                                onRewind: { /* optional */ },
                                onNope: { swipeProgrammatic(left: true, width: geo.size.width) },
                                onLike: { swipeProgrammatic(left: false, width: geo.size.width) },
                                onChat: { /* TODO: open matches/messages */ }
                            )
                            .padding(.bottom, geo.safeAreaInsets.bottom + 10) // ✅ keeps buttons above TabView bar
                        }

                        // Loading / error
                        if vm.isLoading {
                            LoadingOverlay()
                        }

                        if let msg = vm.errorMessage, !msg.isEmpty {
                            Toast(message: msg)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(999)
                        }

                        // Match overlay
                        if vm.showMatchOverlay {
                            MatchOverlay(
                                brand: brand,
                                matchedName: vm.matchedName,
                                onKeepSwiping: { vm.closeMatch() },
                                onMessage: {
                                    // TODO: route to chat using vm.matchedId
                                    vm.closeMatch()
                                }
                            )
                            .transition(.opacity)
                            .zIndex(1000)
                        }
                    }
                }
            }
            .task { await vm.loadIfNeeded() }
        }
    }

    // MARK: - Card Stack
    private func cardStack(size: CGSize) -> some View {
        ZStack {
            ForEach(Array(vm.deck.prefix(3).enumerated()), id: \.element.id) { index, profile in
                let isTop = index == 0

                ProfileCardView(
                    profile: profile,
                    brand: brand,
                    bottomInsetForButtons: 160
                )
                .frame(width: size.width, height: size.height)
                .scaleEffect(isTop ? 1.0 : (1.0 - CGFloat(index) * 0.03))
                .offset(y: isTop ? 0 : CGFloat(index) * 10)
                .overlay(alignment: .topLeading) {
                    if isTop {
                        SwipeStampOverlay(offset: dragOffset)
                            .padding(.top, 62)
                            .padding(.horizontal, 16)
                    }
                }
                .offset(isTop ? dragOffset : .zero)
                .rotationEffect(isTop ? Angle(degrees: Double(dragOffset.width / 18)) : .zero)
                .zIndex(isTop ? 10 : Double(3 - index))
                .animation(.spring(response: 0.28, dampingFraction: 0.85), value: dragOffset)
                .gesture(isTop ? dragGesture(cardWidth: size.width) : nil)
            }
        }
    }

    private func dragGesture(cardWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold = cardWidth * 0.28
                let shouldSwipeRight = value.translation.width > threshold
                let shouldSwipeLeft = value.translation.width < -threshold

                if shouldSwipeRight {
                    swipeProgrammatic(left: false, width: cardWidth)
                } else if shouldSwipeLeft {
                    swipeProgrammatic(left: true, width: cardWidth)
                } else {
                    dragOffset = .zero
                }
            }
    }

    // MARK: - Programmatic swipe (buttons + end of drag)
    private func swipeProgrammatic(left: Bool, width: CGFloat) {
        let flyOutX = left ? -width * 1.2 : width * 1.2
        let flyOut = CGSize(width: flyOutX, height: 40)

        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            dragOffset = flyOut
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            dragOffset = .zero

            if left {
                vm.swipeLeft()
            } else {
                vm.swipeRight()
            }
        }
    }
}

// MARK: - Top Bar (LOCKED height; logo is NOT inside)
private struct TopBar: View {
    var onGear: () -> Void
    private let barHeight: CGFloat = 64

    var body: some View {
        Color.white
            .ignoresSafeArea(edges: .top)
            .frame(height: barHeight)   // ✅ fixed bar height
            .overlay(alignment: .bottomTrailing) {
                Button(action: onGear) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.45))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .padding(.trailing, 10)
                .padding(.bottom, 6)
            }
            .overlay(alignment: .bottom) {
                Divider().opacity(0.15)
            }
    }
}

/// MARK: - Card View (full-screen photo + bottom overlay like screenshot)
private struct ProfileCardView: View {
    let profile: AppUser
    let brand: Color
    let bottomInsetForButtons: CGFloat

    var body: some View {
        ZStack {
            cardImage
                .ignoresSafeArea()
                .overlay {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.00),
                            Color.black.opacity(0.15),
                            Color.black.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }

            VStack(alignment: .leading, spacing: 10) {
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))

                    Text(locationText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                }
                .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 2)

                // Big translucent name/age
                Text("\(profile.firstName) \(profile.age)")
                    .font(.system(size: 58, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.35))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .padding(.top, -6)

                // Bio with quote
                Text("\"\(aboutMeText)\"")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(2)
                    .shadow(color: .black.opacity(0.55), radius: 10, x: 0, y: 2)

                Spacer().frame(height: bottomInsetForButtons)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
    }

    // ✅ MUST be outside body (struct scope)

    private var locationText: String {
        // If your AppUser has city as a String (not optional), adjust accordingly.
        // You previously wrote profile.city ?? "" but AppUser in your model didn’t show city.
        // So: safest is to use location stored elsewhere or default.
        let city = (profile.city ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if city.isEmpty { return "Nearby" }
        return city
    }

    private var aboutMeText: String {
        // If AboutMe is a model, convert it to a display string.
        if let about = profile.aboutMe {
            // If AboutMe has a "text" field, use: return about.text
            return String(describing: about)
        }
        return "Here for something meaningful."
    }

    private var bestPhotoURL: URL? {
        let first = profile.photoURLs.first
        let s = (profile.mainPhotoURL?.isEmpty == false) ? profile.mainPhotoURL : first
        guard let s, !s.isEmpty else { return nil }
        return URL(string: s)
    }

    @ViewBuilder
    private var cardImage: some View {
        if let url = bestPhotoURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Image("signup_bg").resizable().scaledToFill()
                }
            }
        } else {
            Image("signup_bg").resizable().scaledToFill()
        }
    }
}

// MARK: - LIKE / NOPE overlay
private struct SwipeStampOverlay: View {
    let offset: CGSize

    var body: some View {
        HStack {
            if offset.width > 30 {
                stamp(text: "LIKE", systemImage: "heart.fill", rotation: -12)
                Spacer()
            } else if offset.width < -30 {
                stamp(text: "NOPE", systemImage: "xmark", rotation: 12)
                Spacer()
            }
        }
        .animation(.easeOut(duration: 0.12), value: offset.width)
    }

    private func stamp(text: String, systemImage: String, rotation: Double) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).font(.headline)
            Text(text).font(.headline).bold()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.white.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.75), lineWidth: 2)
        )
        .foregroundStyle(.white)
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Action buttons row
private struct ActionBar: View {
    let brand: Color
    var onRewind: () -> Void
    var onNope: () -> Void
    var onLike: () -> Void
    var onChat: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            round(icon: "arrow.counterclockwise", size: 56, action: onRewind)
            round(icon: "xmark", size: 62, action: onNope)

            Button(action: onLike) {
                ZStack {
                    Circle()
                        .fill(brand)
                        .frame(width: 78, height: 78)
                        .shadow(color: .black.opacity(0.35), radius: 14, x: 0, y: 6)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                }
                .contentShape(Circle())
            }
            .buttonStyle(.plain)

            round(icon: "message.fill", size: 62, action: onChat)
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    private func round(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Match Overlay
private struct MatchOverlay: View {
    let brand: Color
    let matchedName: String
    var onKeepSwiping: () -> Void
    var onMessage: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                Text("It’s a Match!")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)

                Text("You and \(matchedName) liked each other.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                HStack(spacing: 12) {
                    Button(action: onKeepSwiping) {
                        Text("Keep Swiping")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white.opacity(0.18))
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)

                    Button(action: onMessage) {
                        Text("Message")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(brand)
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 18)

                Spacer()
            }
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Loading overlay
private struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
        }
    }
}

// MARK: - Toast
private struct Toast: View {
    let message: String
    var body: some View {
        VStack {
            HStack {
                Text(message)
                    .font(.footnote).bold()
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                Spacer()
            }
            .background(.black.opacity(0.55))
            .cornerRadius(14)
            .padding(.horizontal, 14)
            .padding(.top, 8)

            Spacer()
        }
    }
}

// MARK: - Empty state
private struct EmptyDiscoverState: View {
    var onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Text("No more profiles")
                .font(.title3).bold()
                .foregroundStyle(.white)

            Text("Try refreshing or adjust your preferences.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))

            Button("Refresh") { onRefresh() }
                .font(.headline)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(.white.opacity(0.18))
                .cornerRadius(14)
                .foregroundStyle(.white)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    MainTabView()
}
