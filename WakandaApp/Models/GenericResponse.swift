//
//  GenericResponse.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 13/05/21.
//

import Foundation

struct Response<T: Decodable>: Decodable {
    
    let code: Int?
    let message: String?
    let data: T?
}

struct EmptyModel: Decodable { }
