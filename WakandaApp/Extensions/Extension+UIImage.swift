//
//  Extension+UIImage.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 02/07/21.
//

import UIKit

extension UIImage {
    
    var imageName: String {
        return accessibilityIdentifier ?? ""
    }
    
    convenience init?(imageName: String, accessibilityIdentifier: String? = nil) {
        self.init(named: imageName)
        self.accessibilityIdentifier = accessibilityIdentifier != nil ? accessibilityIdentifier : imageName
    }
    
    convenience init?(imageNameInDD: String, accessibilityIdentifier: String? = nil) {
        var localImageURL = FileManager.default.createURLInDD("\(imageNameInDD).jpeg")
        if imageNameInDD.contains(".jpeg") {
            localImageURL = FileManager.default.createURLInDD(imageNameInDD)
        }
        self.init(contentsOfFile: localImageURL.path)
        self.accessibilityIdentifier = accessibilityIdentifier != nil ? accessibilityIdentifier : imageNameInDD
    }
    
    static var parcelPlaceHolderImage: UIImage {
        return UIImage(named: "icn_parcel_place_holder")!
    }
}
