//
//  PhoneVerificationView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct PhoneVerificationView: View {
    @ObservedObject var authVM: AuthViewModel

    @State private var phone = ""
    @State private var code = ""
    @State private var step: Step = .enterPhone

    enum Step { case enterPhone, enterCode }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Verify Your Phone")
                    .font(.title2).bold()
                    .foregroundStyle(.white)

                Text("CeleConnect uses phone verification to keep the community safe and authentic.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                if step == .enterPhone {
                    TextField("+1 555 123 4567", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)

                    Button {
                        Task {
                            await authVM.startPhoneVerification(phoneNumber: phone)
                            if authVM.verificationID != nil { step = .enterCode }
                        }
                    } label: {
                        Text("Send Code").bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white.opacity(0.15))
                            .cornerRadius(14)
                            .foregroundStyle(.white)
                    }
                } else {
                    TextField("123456", text: $code)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)

                    Button {
                        Task { await authVM.confirmAndLinkPhone(smsCode: code) }
                    } label: {
                        Text("Verify").bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white.opacity(0.15))
                            .cornerRadius(14)
                            .foregroundStyle(.white)
                    }

                    Button("Resend code") {
                        step = .enterPhone
                        authVM.verificationID = nil
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
                }

                if let err = authVM.phoneError {
                    Text(err).font(.footnote).foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
    }
}
