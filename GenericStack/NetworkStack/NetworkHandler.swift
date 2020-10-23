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
}

class NetworkHandler: NetworkHandlerProtocol {
    
    @Inject private var sessionManager: SessionManagerProtocol
    
    private func verifyResponse(response: AFDataResponse<Data>) -> NetworkError? {
        return nil
    }
    
    func request(_ request: URLRequestConvertible) -> Future<Data> {
        let promise = Promise<Data>()
        
        
        return promise
    }
}
