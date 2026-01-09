//
//  AppGateView.swift
//  CeleConnect
//
//  Created by Deborah on 1/8/26.
//

import SwiftUI
import FirebaseAuth

struct AppGateView: View {
    @ObservedObject var authVM: AuthViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()

    // UI routing state belongs in the View
    private enum Route: Hashable {
        case landing
        case emailSignUp
        case emailLogin
    }

    @State private var route: Route = .landing

    var body: some View {
        Group {
            if authVM.user == nil {
                // You can keep this as your landing screen and use local routing state.
                switch route {
                case .landing:
                    SignUpLandingView(
                        onSignUpTapped: { route = .emailSignUp },
                        onLoginTapped:  { route = .emailLogin },
                        onAppleTapped:  { Task { await authVM.signInWithApple() } },
                        onGoogleTapped: { Task { await authVM.signInWithGoogle() } },
                        onTroubleTapped: {},
                        onTermsTapped:  {}
                    )

                case .emailSignUp:
                    // Replace EmailSignUpView with your real view name
                    CreateAccountView(
                        authVM: authVM,
                        onCreated: { route = .landing }
                    )

                case .emailLogin:
                    // Replace EmailLoginView with your real view name
                    AuthView(
                        authVM: authVM,
                    )
                }

            } else if !authVM.isPhoneLinkedOrVerified {
                // Your struct is PhoneVerifyView (not PhoneVerificationView)
                PhoneVerifyView(authVM: authVM)

            } else if !onboardingVM.didCompleteOnboarding {
                OnboardingFlowView(onboardingVM: onboardingVM)

            } else {
                MainTabView()
            }
        }
        .task {
            await authVM.refreshUserState()
            await onboardingVM.loadState()
        }
        .onChange(of: authVM.user) { _, newUser in
            // Reset route when auth state changes
            if newUser == nil {
                route = .landing
            } else {
                route = .landing
            }
        }
    }
}
