//
//  Extension+UserDefaults.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 10/05/21.
//

import UIKit

extension UserDefaults {
    
    var firstTimeAppOpen: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: #function)
        } set {
            UserDefaults.standard.set(!newValue, forKey: #function)
            UserDefaults.standard.synchronize()
        }
    }
}
