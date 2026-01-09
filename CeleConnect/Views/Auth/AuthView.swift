//
//  AuthView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

//
//  AuthView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI
import GoogleSignInSwift

// MARK: - Auth View
struct AuthView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSecure = true

    init(authVM: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: authVM)
    }

    var body: some View {
        ZStack {

            // Background
            LinearGradient(
                colors: [Color(hex: "#8B1E3F"), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Main Content
            VStack(spacing: 20) {

                Spacer()

                // Logo (fixed size, no layout expansion)
                Image("CCDiscoverLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 200)
                    .fixedSize()

                // Email
                RoundedField(
                    placeholder: "Email Address",
                    text: $email
                )

                // Password
                ZStack(alignment: .trailing) {
                    RoundedField(
                        placeholder: "Password",
                        text: $password,
                        isSecure: isSecure
                    )

                    Button {
                        isSecure.toggle()
                    } label: {
                        Image(systemName: isSecure ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.trailing, 16)
                    }
                }

                // Create Account
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.white.opacity(0.8))
                    Button("Create Account") {
                        // navigate to signup
                    }
                    .fontWeight(.bold)
                }
                .font(.footnote)

                // Login Button
                Button {
                    Task {
                        await viewModel.signInWithEmail(
                            email: email,
                            password: password
                        )
                    }
                } label: {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#a9054b"))
                        .cornerRadius(30)
                        .contentShape(Rectangle())
                }
                .foregroundColor(.white)
                .padding(.top, 10)

                Button("Forgot Password?") {
                    // reset flow
                }
                .foregroundColor(.white.opacity(0.8))
                .font(.footnote)

                Text("Or Sign in With")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)

                // Google
                Button {
                    Task { await viewModel.signInWithGoogle() }
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(30)
                    .contentShape(Rectangle())
                }
                .foregroundColor(.white)

                // Apple
                Button {
                    Task { await viewModel.signInWithApple() }
                } label: {
                    HStack {
                        Image(systemName: "applelogo")
                        Text("Continue with Apple")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(30)
                    .contentShape(Rectangle())
                }
                .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 24)

            // MFA Overlay
            if viewModel.needsMFA {
                MFAChallengeView(authVM: viewModel)
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        AuthView(authVM: AuthViewModel())
    }
}
