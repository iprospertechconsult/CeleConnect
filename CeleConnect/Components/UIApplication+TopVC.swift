//
//  UIApplication+TopVC.swift
//  CeleConnect
//
//  Created by Deborah on 1/6/26.
//

import UIKit

extension UIApplication {
    func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap { $0.windows }
            .first(where: { $0.isHidden == false })?
            .rootViewController

        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
