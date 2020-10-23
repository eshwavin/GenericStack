//
//  SessionManager.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Alamofire

protocol SessionManagerProtocol {
    var session: Session { get }
}

class SessionManager: SessionManagerProtocol, RequestAdapter, RequestRetrier {
    
    lazy var session: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest = 60
        let interceptor = Interceptor(adapter: self, retrier: self)
        let sessionManager = Session(configuration: configuration, interceptor: interceptor)
        return sessionManager
    }()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        completion(.doNotRetry)
    }
}
