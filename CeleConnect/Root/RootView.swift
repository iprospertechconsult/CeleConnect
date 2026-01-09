//
//  RootView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI
import FirebaseFirestore

struct RootView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.needsMFA {
                MFAChallengeView(authVM: authVM)

            } else if authVM.user == nil {
                // IMPORTANT: EntryFlowView needs to use THIS SAME authVM
                EntryFlowView(authVM: authVM)

            } else if !authVM.isPhoneLinkedOrVerified {
                PhoneVerifyView(authVM: authVM)

            } else {
                MainTabView()
            }
        }
        .task {
            // ensures state is correct on cold start / app relaunch
            await authVM.refreshUserState()
        }
    }
}
