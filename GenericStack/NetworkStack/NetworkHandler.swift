//
//  NetworkHandler.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkHandlerProtocol {
    func request(_ request: URLRequestConvertible) -> Future<Data>
    func downloadToDisk(from url: URL, fileManager: FileManager) -> Future<URL>
    func upload(files: [File]?, to request: URLRequestConvertible) -> Future<Data>
}

extension NetworkHandlerProtocol {
    func downloadToDisk(from url: URL, fileManager: FileManager = FileManager.default) -> Future<URL> {
        return downloadToDisk(from: url, fileManager: fileManager)
    }
}

final class NetworkHandler: NetworkHandlerProtocol {
    
    static let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.timeoutIntervalForResource = 20
        
        let manager = Session(configuration: configuration, interceptor: NetworkMiddleware())
        
        return manager
    }()
    
    private func verifyResponse(response: AFDataResponse<Data>) -> NetworkError? {
        
        if let errorCode = (response.error as NSError?)?.code {
            switch errorCode {
            case -999:
                return .cancelled
            case -1009:
                return .noInternetConnection
            case 403:
                return .forbidden
            default:
                return .unknown(description: response.error?.localizedDescription)
            }
        }
        
        guard let _ = response.data else {
            return .invalidData
        }
        
        if let response = response.response, response.statusCode == 401 {
            return .unauthorized
        }
        
        guard let statusCode = response.response?.statusCode else { return nil }
        
        if 500...511 ~= statusCode {
            return .internalServerError(code: statusCode)
        }
        
        if statusCode == 403 {
            return .forbidden
        }
        
        if !(200...299 ~= statusCode) {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: response.data ?? Data(), options: []) as? [String: AnyObject] else { return .internalServerError(code: statusCode) }
            if let message = jsonObject["error"] as? String {
                return .unknown(description: message)
            } else {
                return .internalServerError(code: statusCode)
            }
        }
        
        return nil
    }
    
    func request(_ request: URLRequestConvertible) -> Future<Data> {
        let promise = Promise<Data>()
        
        NetworkHandler.session.request(request).responseData { [weak self] (response) in
            
            guard let self = self else { return }
            
            if let error = self.verifyResponse(response: response) {
                promise.reject(with: error)
                return
            }
            
            switch response.result {
            case .success(let data):
                promise.resolve(with: data)
            case .failure(let error):
                promise.reject(with: error)
            }
            
        }
        
        return promise
    }
    
    func downloadToDisk(from url: URL, fileManager: FileManager = FileManager.default) -> Future<URL> {
        
        let promise = Promise<URL>()
        
        NetworkHandler.session.download(url).responseData { (response) in
            
            if let error = response.error {
                promise.reject(with: error)
                return
            }
            
            switch response.result {
            case .success(let data):
                let uniqueString = ProcessInfo.processInfo.globallyUniqueString
                let fileExtension = url.pathExtension
                do {
                    let newURL = try fileManager.writeToTemporaryDirectory(data, fileName: uniqueString + ".\(fileExtension)")
                    promise.resolve(with: newURL)
                } catch {
                    promise.reject(with: error)
                }
                
            case .failure(let error):
                promise.reject(with: error)
            }
            
        }
        return promise
    }
    
    func upload(files: [File]?, to request: URLRequestConvertible) -> Future<Data> {
        let promise = Promise<Data>()
        
        NetworkHandler.session.upload(multipartFormData: { (formData) in
            if let files = files {
                files.forEach { (file) in
                    formData.append(file.data, withName: file.key, fileName: file.name, mimeType: file.mimeType.rawValue)
                }
            }
            if let parameters = request.parameters {
                parameters.forEach { (key, value) in
                    formData.append("\(value)".data(using: .utf8) ?? Data(), withName: key)
                }
            }
        }, with: request).responseData { [weak self] (response) in
            
            guard let self = self else { return }

            if let error = self.verifyResponse(response: response) {
                promise.reject(with: error)
                return
            }
            
            switch response.result {
            case .success(let data):
                promise.resolve(with: data)
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        
        return promise
    }
    
    private func debugDataResponse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // try to read out a string array
                print(json)
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            print(String(data: data, encoding: .utf8) as Any)
        }
    }
}
