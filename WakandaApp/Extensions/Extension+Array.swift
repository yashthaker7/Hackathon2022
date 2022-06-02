//
//  Extension+Array.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 29/05/21.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
   public subscript(safe index: Index) -> Iterator.Element? {
     return (startIndex <= index && index < endIndex) ? self[index] : nil
   }
}
