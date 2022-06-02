//
//  RequestParameterable.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 13/05/21.
//

import Foundation

protocol RequestParameterable {
    var parameters: [String: Any]? { get }
}

extension RequestParameterable where Self: Encodable {
    
    var parameters: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let para = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            return para
        }
        return nil
    }
}
