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

    var body: some View {
        VStack(spacing: 16) {
            Text("Verify Phone")
                .font(.title2).bold()

            Text("Enter the SMS code sent to your phone")
                .font(.footnote)
                .foregroundStyle(.secondary)

            TextField("123456", text: $code)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)

            Button("Verify") {
                Task {
                    do {
                        try await authVM.resolveMFA(code: code)
                    } catch {
                        self.error = error.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            if let error {
                Text(error).foregroundStyle(.red).font(.footnote)
            }
        }
        .padding()
    }
}
