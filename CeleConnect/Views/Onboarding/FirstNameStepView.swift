//
//  FirstNameStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI

struct FirstNameStepView: View {
    @ObservedObject var vm: OnboardingViewModel
    @State private var showConfirm = false
    @State private var tempName = ""

    private let brand = Color(hex: "#a9054b")

    var body: some View {
        VStack(spacing: 16) {
            Text("What’s your first name?")
                .font(.title2).bold()
                .foregroundStyle(.white)

            TextField("First name", text: $tempName)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)

            Button {
                // basic validation
                let cleaned = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard cleaned.count >= 2 else { return }
                vm.draft.firstName = cleaned
                showConfirm = true
            } label: {
                Text("Continue").bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brand.opacity(0.9))
                    .cornerRadius(18)
                    .foregroundStyle(.white)
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding()
        .onAppear { tempName = vm.draft.firstName }
        .sheet(isPresented: $showConfirm) {
            WelcomeNameConfirmSheet(
                name: vm.draft.firstName,
                brand: brand,
                onLetsGo: {
                    showConfirm = false
                    vm.next()
                },
                onEdit: {
                    showConfirm = false
                }
            )
            .presentationDetents([.fraction(0.5)])
            .presentationCornerRadius(24)
        }
    }
}

struct WelcomeNameConfirmSheet: View {
    let name: String
    let brand: Color
    let onLetsGo: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("👋")
                .font(.system(size: 44))

            Text("Welcome, \(name)!")
                .font(.title2).bold()

            Text("There’s a lot to discover out there. But let’s get your profile set up first.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)

            Button(action: onLetsGo) {
                Text("Let’s go").bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(brand)
                    .foregroundStyle(.white)
                    .cornerRadius(22)
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)

            Button(action: onEdit) {
                Text("Edit name").bold()
            }
            .padding(.top, 2)

            Spacer(minLength: 0)
        }
        .padding(.top, 18)
        .padding(.horizontal, 16)
    }
}
