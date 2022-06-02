//
//  Extension+UIStoryboard.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 28/04/21.
//  Copyright © 2020 Yash Thaker. All rights reserved.
//

import UIKit

protocol TYStoryboardIdentifiable: TYIdentifiable { }
extension UIViewController: TYStoryboardIdentifiable { }

extension UIStoryboard {

    enum Storyboard: String {
        case signIn     = "SignIn"
        case main       = "Main"
        case settings   = "Settings"
        
        var fileName: String {
            return rawValue
        }
    }
    
    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.fileName, bundle: bundle)
    }
    
    func instantiateVC<T: UIViewController>() -> T {
        guard let viewController = instantiateViewController(identifier: T.identifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.identifier) ")
        }
        return viewController
    }
}
