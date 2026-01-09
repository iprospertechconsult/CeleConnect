//
//  LocationManager.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var city: String?
    @Published var country: String?
    @Published var isAuthorized: Bool = false

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        isAuthorized = (status == .authorizedAlways || status == .authorizedWhenInUse)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        // ✅ Do reverse geocoding in a Task so we can use async APIs on iOS 26+
        Task { [weak self] in
            guard let self else { return }
            await self.reverseGeocode(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error:", error.localizedDescription)
    }

    // MARK: - Reverse geocoding

    private func reverseGeocode(_ location: CLLocation) async {
        if #available(iOS 26.0, *) {
            await reverseGeocode_iOS26(location)
        } else {
            await reverseGeocode_legacy(location)
        }
    }

    @available(iOS 26.0, *)
    private func reverseGeocode_iOS26(_ location: CLLocation) async {
        do {
            guard let request = MKReverseGeocodingRequest(location: location) else {
                self.city = nil
                self.country = nil
                return
            }

            // MapKit geocoding result
            let items = try await request.mapItems
            let item = items.first

            // Best-effort “city” from addressRepresentations
            // (these are display-friendly strings)
            let cityText =
                item?.addressRepresentations?.cityName ??
                item?.addressRepresentations?.cityWithContext

            // Best-effort “country”: often the last component of fullAddress
            let full = item?.address?.fullAddress ?? ""
            let parsedCountry = full
                .split(whereSeparator: { $0 == "\n" })
                .last
                .map(String.init)

            self.city = cityText
            self.country = parsedCountry
        } catch {
            // If MapKit geocoding fails, clear results (or keep old—your call)
            self.city = nil
            self.country = nil
            print("📍 Reverse geocode (iOS26) error:", error.localizedDescription)
        }
    }

    private func reverseGeocode_legacy(_ location: CLLocation) async {
        // CLGeocoder is deprecated in iOS 26, but still fine for iOS < 26
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }

            let place = placemarks?.first
                        let newCity = place?.locality
                        let newCountry = place?.country

                        // ✅ Hop back to the MainActor before mutating @Published properties
                        Task { @MainActor in
                            self.city = newCity
                            self.country = newCountry
                        }

                        if let error {
                            print("📍 Reverse geocode (legacy) error:", error.localizedDescription)
                        }
                    }
                }
            }
