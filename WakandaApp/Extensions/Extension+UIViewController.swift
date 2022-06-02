//
//  Extension+UIViewController.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 28/04/21.
//

import UIKit

extension UIViewController {
    
    // MARK:- Network Observer
    func addNetworkObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(networkNotReachable(_:)), name: .networkNotReachable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(networkReachable(_:)), name: .networkReachable, object: nil)
    }
    
    func removeNetworkObserver() {
        NotificationCenter.default.removeObserver(self, name: .networkNotReachable, object: nil)
        NotificationCenter.default.removeObserver(self, name: .networkReachable, object: nil)
    }
    
    @objc func networkNotReachable(_ notifiaction: Notification) {
    }
    
    @objc func networkReachable(_ notifiaction: Notification) {
    }
    
    // MARK:- App State Observer
    func addAppStateObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    func removeAppStateObserver() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appEnterBackground(_ notifiaction: Notification) {
    }
    
    @objc func appEnterForeground(_ notifiaction: Notification) {
    }

}
