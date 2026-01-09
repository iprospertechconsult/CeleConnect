//
//  NotificationsStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI
import UserNotifications

struct NotificationsStepView: View {

    @ObservedObject var vm: OnboardingViewModel
    @StateObject private var push = PushPermissionManager()

    @State private var isRequesting = false
    @State private var errorText: String?

    private let brand = Color(hex: "#8B1E3F")

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(brand)

            Text("Turn on notifications")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Get notified when someone likes you, matches with you, or sends a message.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Optional faith-friendly line (kept subtle)
            Text("Stay connected with the people God places in your path.")
                .font(.footnote)
                .foregroundStyle(.gray.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {

                Button {
                    Task { await enableNotifications() }
                } label: {
                    HStack(spacing: 10) {
                        if isRequesting {
                            ProgressView()
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        Text(isRequesting ? "Requesting…" : "Enable Notifications")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brand)
                    .cornerRadius(16)
                }
                .disabled(isRequesting)

                Button {
                    // user chose not now
                    vm.notificationsEnabled = false
                    vm.next()
                } label: {
                    Text("Not now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.10))
                        .cornerRadius(16)
                }

                if let errorText {
                    Text(errorText)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Shows current status (nice for debugging & clarity)
            statusPill

        }
        .padding()
        .onAppear {
            push.refreshStatus()
        }
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(push.statusDot)

            Text(push.statusText)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(999)
    }

    private func enableNotifications() async {
        errorText = nil
        isRequesting = true
        defer { isRequesting = false }

        do {
            let granted = try await push.requestPermission()
            vm.notificationsEnabled = granted
            vm.next()
        } catch {
            errorText = error.localizedDescription
        }
    }
}
