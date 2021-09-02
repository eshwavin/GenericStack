//
//  AuthRouter.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Alamofire

enum AuthRouter: URLRequestConvertible {
    case login(parameters: Encodable)
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .login(let parameters):
            return try? parameters.asDictionary()
        }
    }
    
    var pathParameters: [String: Any]? {
        return nil
    }
    
    var url: URL {
        let endpoint: String
        switch self {
        case .login:
            endpoint = NetworkConstants.AuthenticationEndpoints.login
        }
        return URL(string: NetworkConstants.baseURL)!.appendingPathComponent(endpoint)
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .login:
            return JSONEncoding.default
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}

