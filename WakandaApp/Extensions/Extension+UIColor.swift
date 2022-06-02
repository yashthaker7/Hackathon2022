//
//  Extension+UIColor.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 28/04/21.
//

import UIKit

public extension UIColor {

    static var appBlue: UIColor { return UIColor(named: #function) ?? .black }
    static var appDimBlue: UIColor { return UIColor(named: #function) ?? .black }
    static var appDarkDimBlue: UIColor { return UIColor(named: #function) ?? .black }
    static var appTableHeader: UIColor { return UIColor(named: #function) ?? .black }
    static var appNaviBlue: UIColor { return UIColor(named: #function) ?? .black }
    
    static var appDimText: UIColor { return UIColor(named: #function) ?? .black }
    static var appDimText2: UIColor { return UIColor(named: #function) ?? .black }
    static var appTextFieldBorder: UIColor { return UIColor(named: #function) ?? .black }

    static var appDarkGray: UIColor { return UIColor(named: #function) ?? .black }
    static var appLightGray: UIColor { return UIColor(named: #function) ?? .black }
    static var appDimViewColor: UIColor { return UIColor(named: #function) ?? .black }
    
    static var appGreen: UIColor { return UIColor(named: #function) ?? .black }
    static var appDimGreen: UIColor { return UIColor(named: #function) ?? .black }
    static var appRed: UIColor { return UIColor(named: #function) ?? .black }
    static var appDimRed: UIColor { return UIColor(named: #function) ?? .black }
    
    static var routeStatusDraft: UIColor { return UIColor(named: #function) ?? .black }
    static var routeStatusDraftBG: UIColor { return UIColor(named: #function) ?? .black }
    static var routeStatusActive: UIColor { return UIColor(named: #function) ?? .black }
    static var routeStatusActiveBG: UIColor { return UIColor(named: #function) ?? .black }
    
    convenience init?(hexRGB: String) {
        if hexRGB == "#000" {
            self.init(white: 0, alpha: 1)
            return
        }
        self.init(hexRGBA: hexRGB + "ff")
    }
    
    convenience init?(hexRGBA: String) {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
        
        if hexRGBA.hasPrefix("#") {
            let start = hexRGBA.index(hexRGBA.startIndex, offsetBy: 1)
            let hexColor = String(hexRGBA[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
