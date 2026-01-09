//
//  EnrollMFAView.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import SwiftUI

struct EnrollMFAView: View {
    @StateObject var authVM: AuthViewModel

    @State private var phone = ""        // must be E.164: +14045551234
    @State private var code = ""
    @State private var verificationID: String?
    @State private var status: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("Enable Phone MFA").font(.title2).bold()
            Text("Phone must include country code (E.164). Example: +14045551234")
                .font(.footnote).foregroundStyle(.secondary)

            TextField("+1...", text: $phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)

            if verificationID == nil {
                Button("Send Code") {
                    Task {
                        do {
                            let vid = try await authVM.startEnrollPhoneMFA(phoneNumberE164: phone)
                            verificationID = vid
                            status = "Code sent."
                        } catch {
                            status = error.localizedDescription
                        }
                    }
                }
            } else {
                TextField("123456", text: $code)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Button("Verify & Enable MFA") {
                    Task {
                        do {
                            try await authVM.finishEnrollPhoneMFA(
                                verificationID: verificationID!,
                                code: code,
                                firstName: "SMS"
                            )
                            status = "✅ MFA enabled!"
                        } catch {
                            status = error.localizedDescription
                        }
                    }
                }
            }

            if let status {
                Text(status).font(.footnote)
            }
        }
        .padding()
    }
}
