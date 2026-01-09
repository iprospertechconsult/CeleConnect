//
//  MFAChallengeView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct MFAChallengeView: View {

    @ObservedObject var authVM: AuthViewModel
    @State private var code = ""
    @State private var error: String?
    @State private var isVerifying = false

    private let brand = Color(hex: "#8B1E3F")

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [brand, .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Verify Phone")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Enter the 6-digit code sent to your phone")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                // Code Field
                TextField("123456", text: $code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .frame(maxWidth: 220)
                    .onChange(of: code) {
                        // Limit to 6 digits
                        code = String(code.prefix(6))
                    }

                // Error
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                // Verify Button
                Button {
                    Task {
                        await verifyCode()
                    }
                } label: {
                    HStack {
                        if isVerifying {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Verify")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(code.count == 6 ? brand : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(code.count != 6 || isVerifying)

                Spacer()
            }
            .padding()
        }
    }

    private func verifyCode() async {
        error = nil
        isVerifying = true
        do {
            try await authVM.resolveMFA(code: code)
        } catch {
            self.error = error.localizedDescription
        }
        isVerifying = false
    }
}
#Preview {
    let previewVM = AuthViewModel()
    return MFAChallengeView(authVM: previewVM)
}
