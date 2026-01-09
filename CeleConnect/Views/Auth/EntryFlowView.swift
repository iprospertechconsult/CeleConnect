//
//  EntryFlowView.swift
//  CeleConnect
//
//  Created by Deborah on 1/7/26.
//
//
//  EntryFlowView.swift
//  CeleConnect
//
//  Created by Deborah on 1/7/26.
//

import SwiftUI

struct EntryFlowView: View {
    @ObservedObject var authVM: AuthViewModel   // ✅ use the one from RootView

    @State private var showLogin = false
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            SignUpLandingView(
                onSignUpTapped: { showSignUp = true },
                onLoginTapped: { showLogin = true },
                onAppleTapped: { Task { await authVM.signInWithApple() } },
                onGoogleTapped: { Task { await authVM.signInWithGoogle() } },
                onTroubleTapped: { /* open help screen */ },
                onTermsTapped: { /* open terms screen */ }
            )
            .navigationDestination(isPresented: $showLogin) {
                AuthView(authVM: authVM) // ✅ same instance
            }
            .navigationDestination(isPresented: $showSignUp) {
                CreateAccountView(authVM: authVM) // ✅ same instance
            }
        }
    }
}

#Preview {
    EntryFlowView(authVM: AuthViewModel()) // preview needs a VM
}
