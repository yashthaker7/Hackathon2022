//
//  WakandaAppService.swift
//  WakandaApp
//
//  Created by SOTSYS138 on 12/05/21.
//

import UIKit
import Alamofire

public class WakandaAppService: Service {
    
    override var apiBaseURLStr: APIBaseURLStr {
        return .baseURL
    }
    
    override internal var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        let dateFormatters = [DateFormatter.standardUTC,
                              DateFormatter.yearMonthDay,
                              DateFormatter.hourMinuteSecond]
        jsonDecoder.dateDecodingStrategyFormatters = dateFormatters
        return jsonDecoder
    }
    
    @discardableResult internal func requestData<T: Decodable>(_ apiName: APIName,
                                                               method: HTTPMethod = .get,
                                                               parameters: Parameters? = nil,
                                                               encoding: ParameterEncoding = JSONEncoding.default,
                                                               headers: HTTPHeaders? = nil,
                                                               completion: @escaping (Result<Response<T>, ServiceError>) -> ()) -> DataRequest {
        let urlStr = apiBaseURLStr.rawValue + apiName.rawValue
        print("API Called", urlStr)
        let request = AF.request(urlStr, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseData { (response) in
                self.handleResponse(response, completion: completion)
            }
        return request
    }
    
    private func handleResponse<T: Decodable>(_ response: AFDataResponse<Data>, completion: @escaping (Result<Response<T>, ServiceError>) -> ()) {
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
            let model = try self.decoder.decode(Response<T>.self, from: data)
            if let code = model.code, let message = model.message,
               let serviceError = ServiceError(code: code, message: message) {
                completion(.failure(serviceError))
                return
            }
            completion(.success(model))
        } catch let error {
            print("Error", error)
            completion(.failure(ServiceError(error)))
        }
    }
    
    @discardableResult internal func uploadImages<T: Decodable>(_ apiName: APIName,
                                                               method: HTTPMethod = .get,
                                                               parameters: Parameters? = nil,
                                                               headers: HTTPHeaders? = nil,
                                                               uploadProgress: @escaping (Double) -> (),
                                                               completion: @escaping (Result<Response<T>, ServiceError>) -> ()) -> UploadRequest {
        let multipartFormDataBlock = { (multipartFormData: MultipartFormData) in
            if let parameters = parameters {
                for (key, value) in parameters {
                    if let image = value as? UIImage {
                        guard let imageData = image.jpegData(compressionQuality: 0.5) else { continue }
                        let fileName = "\(Date().timeIntervalSince1970).jpeg"
                        multipartFormData.append(imageData, withName: key, fileName: fileName, mimeType: "image/jpeg")
                    } else {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
            }
        }
        let urlStr = apiBaseURLStr.rawValue + apiName.rawValue
        print("API Called", urlStr)
        let request = AF.upload(multipartFormData: multipartFormDataBlock, to: urlStr, usingThreshold: UInt64.init(), method: .post, headers: headers).uploadProgress(queue: .main) { progress in
            uploadProgress(progress.fractionCompleted)
        }.responseData { (response) in
            self.handleResponse(response, completion: completion)
        }
        return request
    }
        
    @discardableResult internal func downloadImage(_ imageURL: String, completion: @escaping (Result<UIImage, ServiceError>) -> ()) -> DataRequest {
        let request = AF.request(imageURL, method: .get).responseData { (response) in
            if let error = response.error {
                completion(.failure(ServiceError(error)))
                return
            }
            guard let data = response.data else {
                completion(.failure(ServiceError(.noResponse)))
                return
            }
            guard let image = UIImage(data: data) else {
                completion(.failure(ServiceError(.imageNotFound)))
                return
            }
            completion(.success(image))
        }
        return request
    }
    
    class func getAllTask(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        AF.session.getAllTasks(completionHandler: completionHandler)
    }
}


