import SwiftUI
import FirebaseAuth

struct RootAppGateView: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()

    private enum Route: Hashable { case landing, emailSignUp, emailLogin }
    @State private var route: Route = .landing

    var body: some View {
        Group {
            // 0) MFA
            if authVM.needsMFA {
                MFAChallengeView(authVM: authVM)
            }

            // 1) Logged out -> landing / login / signup
            else if authVM.user == nil {
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
                    CreateAccountView(
                        authVM: authVM,
                        onCreated: { route = .landing }
                    )

                case .emailLogin:
                    AuthView(authVM: authVM)
                }
            }

            // 2) Phone verification MUST happen right after account creation / login
            else if !authVM.isPhoneLinkedOrVerified {
                NavigationStack { PhoneVerifyView(authVM: authVM) }
            }

            // 3) Rules agreement gate
            else if authVM.needsRulesAgreement {
                RulesAgreementView(authVM: authVM)
            }

            // 4) Onboarding gate
            else if authVM.needsOnboarding {
                OnboardingFlowView(
                    onboardingVM: onboardingVM,
                    onFinished: { Task { await authVM.refreshUserState() } }
                )
            }

            // 5) Fully in
            else {
                MainTabView()
            }
        }
        // ✅ Run once when the view appears
        .task {
            await authVM.refreshUserState()
            if authVM.user != nil {
                await onboardingVM.loadState()
            }
        }
        // ✅ Only react to actual UID changes
        .onChange(of: authVM.user?.uid) { oldUID, newUID in
            route = .landing

            // If we logged out, don't touch Firestore
            guard newUID != nil else { return }

            Task {
                await authVM.refreshUserState()
                await onboardingVM.loadState()
            }
        }
    }
}
