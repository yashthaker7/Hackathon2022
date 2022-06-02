//
//  Service.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 06/08/21.
//

import UIKit
import Alamofire

public class Service: NSObject {
    
    internal var apiBaseURLStr: APIBaseURLStr {
        return .baseURL
    }
    
    internal var headers: HTTPHeaders {
        return ["Content-Type": "application/json"]
    }
    
    internal var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    override init() {
        super.init()
        
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
    }
   
    @discardableResult internal func requestData<T: Decodable>(_ apiName: APIName,
                                                               method: HTTPMethod = .get,
                                                               parameters: Parameters? = nil,
                                                               encoding: ParameterEncoding = JSONEncoding.default,
                                                               headers: HTTPHeaders? = nil,
                                                               completion: @escaping (Result<T, ServiceError>) -> ()) -> DataRequest {
        let urlStr = apiBaseURLStr.rawValue + apiName.rawValue
        print("API Called", urlStr)
        let request = AF.request(urlStr, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseData { (response) in
                self.handleResponse(response, completion: completion)
            }
        return request
    }
        
    private func handleResponse<T: Decodable>(_ response: AFDataResponse<Data>, completion: @escaping (Result<T, ServiceError>) -> ()) {
        if let error = response.error {
            completion(.failure(ServiceError(error)))
            return
        }
        guard let data = response.data else {
            completion(.failure(ServiceError(.noResponse)))
            return
        }
        // print(try? JSONSerialization.jsonObject(with: data) as? [String: Any])
        do {
            let model = try self.decoder.decode(T.self, from: data)
            completion(.success(model))
        } catch let error {
            print("Error", error)
            completion(.failure(ServiceError(error)))
        }
    }
}
