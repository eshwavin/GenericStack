//
//  URLRequestConvertible.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 22/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Alamofire

protocol URLRequestConvertible: Alamofire.URLRequestConvertible {
    
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var pathParameters: [String: Any]? { get }
    var url: URL { get }
    var encoding: ParameterEncoding { get }
    var headers: [String: String]? { get }
    
}

extension URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        let url = self.url.withPathParameters(pathParameters)
        var urlRequest = URLRequest(url: url)
        
        if let headers = headers {
            for (field, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: field)
            }
        }
        
        urlRequest.httpMethod = method.rawValue
        return try encoding.encode(urlRequest, with: parameters)
    }
    
}
