//
//  LocationStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

//
//  LocationStepView.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import SwiftUI
import CoreLocation

struct LocationStepView: View {

    @ObservedObject var vm: OnboardingViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var manualCity: String = ""
    @State private var allowWorldwide = true
    @State private var showError = false

    private let brand = Color(hex: "#8B1E3F")

    var body: some View {
        VStack(spacing: 28) {

            Spacer()

            // MARK: - Title
            Text("Where are you located?")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("This helps us find meaningful connections near you—or anywhere God leads you.")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // MARK: - Location Button
            Button {
                locationManager.requestLocation()
            } label: {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Use My Current Location")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(brand)
                .cornerRadius(14)
            }

            // MARK: - Manual City Entry
            VStack(alignment: .leading, spacing: 6) {
                Text("Or enter your city manually")
                    .font(.footnote)
                    .foregroundStyle(.gray)

                TextField("City, State / Country", text: $manualCity)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)

            // MARK: - Worldwide Toggle
            Toggle(isOn: $vm.allowWorldwide) {
                Text("Show profiles worldwide")
                    .foregroundStyle(.white)
            }
            .tint(brand)
            .padding(.horizontal)

            Spacer()

            // MARK: - Continue Button
            Button {
                saveAndContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canContinue ? brand : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(!canContinue)

        }
        .padding()
        .onChange(of: locationManager.city) {
            manualCity = locationManager.city ?? ""
        }
        .alert("Location Needed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please allow location access or enter your city manually.")
        }
    }

    // MARK: - Logic

    private var canContinue: Bool {
        !manualCity.isEmpty || locationManager.city != nil
    }

    private func saveAndContinue() {
        guard canContinue else {
            showError = true
            return
        }

        vm.locationCity = manualCity
        vm.allowWorldwide = allowWorldwide
        vm.next()
    }
}
