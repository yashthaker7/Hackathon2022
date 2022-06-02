//
//  Extension+UIFont.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 04/05/21.
//

import UIKit

extension UIFont {
    
    enum AppFont: String {
        case PoppinsRegular    = "Poppins-Regular"
        case PoppinsMedium     = "Poppins-Medium"
        case PoppinsSemiBold   = "Poppins-SemiBold"
        case PoppinsBold       = "Poppins-Bold"
        
        var name: String {
            return rawValue
        }
    }
    
    convenience init?(appFont: AppFont, size: CGFloat) {
        self.init(name: appFont.name, size: size)
    }
    
    static func customFonts() {
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
    }
}
