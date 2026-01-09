//
//  PhoneVerifyView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

// MARK: - Country Code Model

struct CountryCode: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let iso2: String
    let dialCode: String
    let flag: String
}

private let countryCodes: [CountryCode] = [
    .init(name: "United States",  iso2: "US", dialCode: "+1",   flag: "🇺🇸"),
    .init(name: "Canada",         iso2: "CA", dialCode: "+1",   flag: "🇨🇦"),
    .init(name: "United Kingdom", iso2: "GB", dialCode: "+44",  flag: "🇬🇧"),
    .init(name: "Nigeria",        iso2: "NG", dialCode: "+234", flag: "🇳🇬"),
    .init(name: "Ghana",          iso2: "GH", dialCode: "+233", flag: "🇬🇭"),
    .init(name: "South Africa",   iso2: "ZA", dialCode: "+27",  flag: "🇿🇦"),
    .init(name: "Kenya",          iso2: "KE", dialCode: "+254", flag: "🇰🇪"),
    .init(name: "France",         iso2: "FR", dialCode: "+33",  flag: "🇫🇷"),
    .init(name: "Germany",        iso2: "DE", dialCode: "+49",  flag: "🇩🇪"),
    .init(name: "Brazil",         iso2: "BR", dialCode: "+55",  flag: "🇧🇷")
]

// MARK: - Helpers

private func digitsOnly(_ s: String) -> String {
    s.filter { $0.isNumber }
}

private func formatPhone(digits: String, dialCode: String) -> String {
    let d = digitsOnly(digits)

    // +1 (US/CA): (XXX) XXX-XXXX
    if dialCode == "+1" {
        let maxLen = min(d.count, 10)
        let d10 = String(d.prefix(maxLen))

        let area = d10.prefix(3)
        let mid  = d10.dropFirst(3).prefix(3)
        let last = d10.dropFirst(6).prefix(4)

        switch d10.count {
        case 0...3:
            return String(area)
        case 4...6:
            return "(\(area)) \(mid)"
        default:
            return "(\(area)) \(mid)-\(last)"
        }
    }

    // Default grouping for other countries
    let maxLen = min(d.count, 15) // typical E.164 max national digits
    let trimmed = String(d.prefix(maxLen))

    if trimmed.count <= 3 { return trimmed }
    if trimmed.count <= 6 { return "\(trimmed.prefix(3)) \(trimmed.dropFirst(3))" }

    let p1 = trimmed.prefix(3)
    let p2 = trimmed.dropFirst(3).prefix(3)
    let p3 = trimmed.dropFirst(6)
    return "\(p1) \(p2) \(p3)"
}

// MARK: - View

struct PhoneVerifyView: View {
    @ObservedObject var authVM: AuthViewModel

    private let brand = Color(hex: "#A9054B")

    // Phone input
    @State private var selectedCountry: CountryCode = countryCodes.first!
    @State private var rawDigits: String = ""
    @State private var phoneDisplay: String = ""

    // Code input
    @State private var code = ""
    @State private var step: Step = .enterPhone

    @State private var isSending = false
    @State private var isVerifying = false

    enum Step { case enterPhone, enterCode }

    private var phoneE164: String {
        "\(selectedCountry.dialCode)\(rawDigits)"
    }

    private var isPhoneValid: Bool {
        if selectedCountry.dialCode == "+1" {
            return rawDigits.count == 10
        }
        return rawDigits.count >= 7
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Whats your digits?")
                    .font(.title).bold()
                    .foregroundStyle(.black)

                HStack {
                    Text("CeleConnect uses phone verification to keep the community safe and authentic.")
                        .font(.subheadline)
                        .foregroundStyle(.black.opacity(0.8))
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                if step == .enterPhone {

                    // MARK: Phone Row (Country + Phone)
                    HStack(spacing: 10) {

                        // Country picker
                        Menu {
                            Picker("Country", selection: $selectedCountry) {
                                ForEach(countryCodes) { c in
                                    Text("\(c.flag) \(c.name) (\(c.dialCode))").tag(c)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(selectedCountry.flag)
                                Text(selectedCountry.dialCode)
                                    .font(.subheadline).bold()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .opacity(0.75)
                            }
                            .foregroundStyle(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(brand.opacity(0.6), lineWidth: 1.5)
                            )
                        }

                        // Phone field (taller + auto-format)
                        TextField("Phone number", text: $phoneDisplay)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.vertical, 16)          // ✅ taller
                            .padding(.horizontal, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(brand.opacity(0.6), lineWidth: 1.5)
                            )
                    }
                    .onChange(of: phoneDisplay) { _, newValue in
                        rawDigits = digitsOnly(newValue)
                        let formatted = formatPhone(digits: rawDigits, dialCode: selectedCountry.dialCode)
                        if formatted != phoneDisplay {
                            phoneDisplay = formatted
                        }
                    }
                    .onChange(of: selectedCountry) { _, _ in
                        phoneDisplay = formatPhone(digits: rawDigits, dialCode: selectedCountry.dialCode)
                    }

                    // MARK: Send Code
                    Button {
                        isSending = true
                        Task {
                            await authVM.startPhoneVerification(phoneNumber: phoneE164)

                            if authVM.phoneVerificationID != nil {
                                step = .enterCode
                            }

                            isSending = false
                        }
                    } label: {
                        Text(isSending ? "Sending..." : "Send Code")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brand)              // ✅ #A9054B
                            .cornerRadius(30)
                            .foregroundStyle(.white)
                    }
                    .disabled(isSending || !isPhoneValid)

                } else {

                    // MARK: Enter Code
                    TextField("123456", text: $code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(brand.opacity(0.6), lineWidth: 1.5)
                        )

                    Button {
                        isVerifying = true
                        Task {
                            await authVM.confirmAndLinkPhone(smsCode: code)
                            isVerifying = false
                        }
                    } label: {
                        Text(isVerifying ? "Verifying..." : "Verify")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brand.opacity(0.92))
                            .cornerRadius(30)
                            .foregroundStyle(.white)
                    }
                    .disabled(isVerifying || code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(isVerifying || code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.7 : 1)

                    Button("Resend code") {
                        code = ""
                        step = .enterPhone
                        authVM.resetPhoneVerification()
                    }
                    .foregroundStyle(brand.opacity(0.9))
                    .padding(.top, 4)
                }

                if let err = authVM.phoneError, !err.isEmpty {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
        .onChange(of: authVM.isPhoneLinkedOrVerified) { _, linked in
            if linked {
                code = ""
                rawDigits = ""
                phoneDisplay = ""
                step = .enterPhone
            }
        }
    }
}

// MARK: - Preview

#Preview {
    struct PhoneVerifyPreviewHost: View {
        @StateObject private var authVM = AuthViewModel()

        var body: some View {
            PhoneVerifyView(authVM: authVM)
        }
    }

    return PhoneVerifyPreviewHost()
}
