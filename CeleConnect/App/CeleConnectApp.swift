//
//  CeleConnectApp.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

//
//  CeleConnectApp.swift
//  CeleConnect
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import UIKit

@main
struct CeleConnectApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
// ✅ ONE AppDelegate — Firebase + APNs forwarding for Phone Auth
final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        // ✅ Required so Firebase Phone Auth can use APNs
        application.registerForRemoteNotifications()

        return true
    }

    // ✅ Pass device token to FirebaseAuth
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Use .sandbox for Debug, .prod for TestFlight/App Store if you want to be explicit.
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    // ✅ Let FirebaseAuth handle its APNs notifications
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
}
