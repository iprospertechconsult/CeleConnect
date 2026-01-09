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
import GoogleSignIn

// ✅ ONE AppDelegate — Firebase only
final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CeleConnectApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                // ✅ iOS 26–safe Google Sign-In handler
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
