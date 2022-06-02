//
//  TYIdentifiable.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 30/04/21.
//

import Foundation

protocol TYIdentifiable {
    static var identifier: String { get }
    var identifier: String { get }
}

extension TYIdentifiable {
    static var identifier: String {
        return String(describing: self)
    }
    var identifier: String {
        return String(describing: self)
    }
}

extension NSObject: TYIdentifiable { }
