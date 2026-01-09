//
//  CreateAccountView.swift
//  CeleConnect
//
//  Created by Deborah on 1/7/26.
//

import SwiftUI

struct CreateAccountView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSecure = true

    var onCreated: (() -> Void)? = nil

    private let topBrand = Color(hex: "#8B1E3F")
    private let buttonBrand = Color(hex: "#8B1E3F")

    init(authVM: AuthViewModel, onCreated: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: authVM)
        self.onCreated = onCreated
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background (maroon -> black)
                LinearGradient(
                    colors: [topBrand, .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // Slight extra dark at very bottom (like screenshot)
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.35)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Header: logo + text
                        BrandHeader()
                            .padding(.top, 30)

                        // Form content
                        VStack(spacing: 16) {
                            PillField(placeholder: "Email Address", text: $email, isSecure: false) {
                                EmptyView()
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)

                            PillField(placeholder: "Password", text: $password, isSecure: isSecure) {
                                Button { isSecure.toggle() } label: {
                                    Image(systemName: isSecure ? "eye.slash" : "eye")
                                        .foregroundColor(.black.opacity(0.35))
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.password)

                            // Create Account
                            Button {
                                Task { await createAccountTapped() }
                            } label: {
                                ZStack {
                                        Capsule()
                                            .fill(buttonBrand.opacity(viewModel.isLoading ? 0.7 : 1.0))

                                        HStack {
                                            if viewModel.isLoading {
                                                ProgressView().tint(.white)
                                            } else {
                                                Text("Create Account")
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .contentShape(Capsule())   // ✅ makes the whole pill tappable
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.isLoading)
                                .padding(.top, 4)

                            // Already have account? Login
                            HStack(spacing: 10) {
                                Text("Already Have an Account?")
                                    .foregroundColor(.white.opacity(0.85))
                                    .font(.system(size: 13, weight: .semibold))

                                Button { dismiss() } label: {
                                    Text("Login")
                                        .foregroundColor(.white)
                                        .font(.system(size: 13, weight: .bold))
                                }
                            }
                            .padding(.top, 10)

                            // Social buttons
                            SocialOutlineButton(
                                title: "Sign Up with Google",
                                leading: {
                                    // If you add an asset named "google_g", it will use it.
                                    // Otherwise it falls back to a simple "G".
                                    if UIImage(named: "google_g") != nil {
                                        Image("google_g")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                    } else {
                                        Text("G")
                                            .font(.system(size: 18, weight: .heavy))
                                            .foregroundColor(.white)
                                    }
                                },
                                action: { Task { await viewModel.signInWithGoogle() } }
                            )
                            .padding(.top, 12)

                            SocialOutlineButton(
                                title: "Sign Up with Apple",
                                leading: {
                                    Image(systemName: "applelogo")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                },
                                action: { Task { await viewModel.signInWithApple() } }
                            )
                        }
                        .padding(.top, 26)
                        .padding(.horizontal, 34)

                        // Push content up a bit like the screenshot (extra bottom space)
                        Spacer(minLength: 80)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .zIndex(1)
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil && !(viewModel.errorMessage ?? "").isEmpty },
                set: { _ in viewModel.errorMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Actions
    private func createAccountTapped() async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isValidEmail(trimmedEmail) else {
            viewModel.errorMessage = "Please enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            viewModel.errorMessage = "Password must be at least 6 characters."
            return
        }

        await viewModel.createAccountWithEmail(email: trimmedEmail, password: password)

        if viewModel.user != nil {
            onCreated?()
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        s.contains("@") && s.contains(".") && s.count >= 6
    }
}

// MARK: - Header (logo + title)
private struct BrandHeader: View {
    var body: some View {
        VStack(spacing: 10) {
            Group {
                if UIImage(named: "celestial_logo") != nil {
                    Image("celestial_logo")
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "heart.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.white.opacity(0.95))
                }
            }
            .frame(width: 200, height: 200)

        }
    }
}

// MARK: - Pill field (gray capsule) — FIXED (generic trailing view)
private struct PillField<Trailing: View>: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let trailing: Trailing

    init(
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.trailing = trailing()
    }

    var body: some View {
            ZStack(alignment: .leading) {

                // ✅ Custom placeholder (WHITE)
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.horizontal, 18)
                }

                HStack(spacing: 10) {
                    Group {
                        if isSecure {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .tint(.white)

                    Spacer(minLength: 0)

                    trailing
                }
                .padding(.horizontal, 18)
            }
            .frame(height: 46)
            .background(
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .fill(Color.white.opacity(0.25)) // pill background
            )
            .overlay(
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }

// MARK: - Social outline capsule
private struct SocialOutlineButton<Leading: View>: View {
    let title: String
    @ViewBuilder var leading: () -> Leading
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .stroke(Color.white.opacity(0.75), lineWidth: 1.2)

                HStack(spacing: 10) {
                    leading()
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .contentShape(Capsule())  // ✅ whole pill tappable
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CreateAccountView(authVM: AuthViewModel())
}
