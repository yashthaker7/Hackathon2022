//
//  Extension+UIApplication.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 30/03/22.
//

import UIKit

extension UIApplication {
  
    static let appName: String = {
        guard let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else { return "" }
        return appName
    }()
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    func getTopMostViewController() -> UIViewController? {
        let window = keyWindow ?? windows.first(where: { $0.isKeyWindow })
        if var topController = window?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
  
}
