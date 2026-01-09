//
//  PushPermissionManager.swift
//  CeleConnect
//
//  Created by Deborah on 1/9/26.
//

import Foundation
import SwiftUI
import UserNotifications
import Combine

@MainActor
final class PushPermissionManager: ObservableObject {

    enum Status {
        case unknown
        case denied
        case authorized
        case provisional
        case ephemeral
        case notDetermined
    }

    @Published private(set) var status: Status = .unknown

    func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                switch settings.authorizationStatus {
                case .denied:
                    self.status = .denied
                case .authorized:
                    self.status = .authorized
                case .provisional:
                    self.status = .provisional
                case .ephemeral:
                    self.status = .ephemeral
                case .notDetermined:
                    self.status = .notDetermined
                @unknown default:
                    self.status = .unknown
                }
            }
        }
    }

    func requestPermission() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        refreshStatus()
        return granted
    }

    var statusText: String {
        switch status {
        case .authorized: return "Notifications enabled"
        case .provisional: return "Notifications provisional"
        case .ephemeral: return "Notifications ephemeral"
        case .denied: return "Notifications denied"
        case .notDetermined: return "Not requested yet"
        case .unknown: return "Status unknown"
        }
    }

    var statusDot: Color {
        switch status {
        case .authorized, .provisional, .ephemeral: return .green
        case .denied: return .red
        case .notDetermined: return .yellow
        case .unknown: return .gray
        }
    }
}
