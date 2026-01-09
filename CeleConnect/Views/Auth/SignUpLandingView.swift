//
//  SignUpLandingView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct SignUpLandingView: View {
    
    var onSignUpTapped: () -> Void
    var onLoginTapped: () -> Void
    var onAppleTapped: () -> Void
    var onGoogleTapped: () -> Void
    var onTroubleTapped: () -> Void
    var onTermsTapped: () -> Void
    
    private let brand = Color(hex: "#a9054b")
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background image - true full screen
                Image("signup_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                // Overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.30),
                        Color.black.opacity(0.70)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        header
                            .padding(.horizontal, 28)
                        
                        Spacer().frame(height: 18)
                        
                        VStack(spacing: 14) {
                            filledCapsule("Sign Up", fill: brand, textColor: .white, action: onSignUpTapped)
                            filledCapsule("Login", fill: .white, textColor: brand, action: onLoginTapped)
                            
                            orRow
                                .padding(.top, 4)
                            
                            outlineCapsule("Continue with Apple", systemImage: "applelogo", action: onAppleTapped)
                            outlineCapsule("Continue with Google", systemImage: "g.circle.fill", action: onGoogleTapped)
                        }
                        .padding(.horizontal, 28)
                        
                        Spacer().frame(height: 18)
                        
                        footer
                            .padding(.horizontal, 28)
                    }
                    // ✅ THIS replaces your topSpacer/bottomSpacer and never “pushes”
                    .padding(.top, geo.safeAreaInsets.top + 44)
                    .padding(.bottom, geo.safeAreaInsets.bottom + 28)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                // ✅ This is critical: binds the scroll view to the visible screen
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 13) {
            Text("Find your date\nMeet your destiny")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)              // left-align lines
                .lineLimit(nil)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .center) // center the block
            
            Text("Give your soulmate a chance.\nTrue Love awaits you here!")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(nil)
                .minimumScaleFactor(0.90)
        }
    }
    
    // MARK: - Or row (two lines + centered “or”)
    private var orRow: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color.white.opacity(0.35))
                .frame(height: 1)
            
            Text("or")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            
            Rectangle()
                .fill(Color.white.opacity(0.35))
                .frame(height: 1)
        }
        .padding(.horizontal, 6)
    }
    
    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 10) {
            Button(action: onTroubleTapped) {
                Text("Trouble logging in?")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .buttonStyle(.plain)
            
            Button(action: onTermsTapped) {
                Text("By selecting to \"Sign Up\" or \"Login\", you agree to\nTerms & Conditions.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(1))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .minimumScaleFactor(0.80)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 6)
    }
    
    // MARK: - Buttons (guaranteed capsules)
    private func filledCapsule(
        _ title: String,
        fill: Color,
        textColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, minHeight: 52)  // ✅ label owns size
                .contentShape(Rectangle())                  // ✅ full area taps
        }
        .buttonStyle(.plain)
        .background(fill, in: Capsule())
    }
    
    private func outlineCapsule(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 52)      // ✅ label owns size
            .contentShape(Rectangle())                      // ✅ full area taps
        }
        .buttonStyle(.plain)
        .background(Color.clear, in: Capsule())
        .overlay(
            Capsule().stroke(Color.white.opacity(0.65), lineWidth: 1)
        )
    }
}

#Preview {
    SignUpLandingView(
        onSignUpTapped: {},
        onLoginTapped: {},
        onAppleTapped: {},
        onGoogleTapped: {},
        onTroubleTapped: {},
        onTermsTapped: {}
    )
}
