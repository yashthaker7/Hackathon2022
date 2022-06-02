//
//  PublicIPAddress.swift
//  WakandaApp
//
//  Created by SOTSYS302 on 09/02/22.
//

import Foundation

final class PublicIP {
    
    typealias CompletionHandler = (String?, Error?) -> Void
    
    class func getPublicIP(completion: @escaping CompletionHandler) {
        
        guard let requestURL = URL(string: "https://api.ipify.org/") else {
            completion(nil, CustomError.URLNotValidate)
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                completion(nil, CustomError.error(error))
                return
            }
            guard let data = data else {
                completion(nil, CustomError.noData)
                return
            }
            guard let result = String(data: data, encoding: .utf8) else {
                completion(nil, CustomError.undecodeable)
                return
            }
            let ipAddress = String(result.filter { !" \n\t\r".contains($0) })
            completion(ipAddress, nil)
        }.resume()
    }
    
    enum CustomError: LocalizedError {
        case URLNotValidate
        case noData
        case error(Error)
        case undecodeable
        
        public var errorDescription: String? {
            switch self {
            case .URLNotValidate:
                return "URL is not validate."
            case .noData:
                return "No data response."
            case .error(let err):
                return err.localizedDescription
            case .undecodeable:
                return "Data undecodeable."
            }
        }
    }
}

