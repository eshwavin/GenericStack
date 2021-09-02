//
//  NetworkMiddleware.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 02/09/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Alamofire

final class NetworkMiddleware: RequestInterceptor {
    
    let maxRetries = 0 // set the count for number of retries
    
    // [Request url: Number of times retried]
    private var retriedRequests: [String: Int] = [:]
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        guard request.task?.response == nil, let url = request.request?.url?.absoluteString else {
            removeCachedUrlRequest(url: request.request?.url?.absoluteString)
            completion(.doNotRetry) // don't retry
            return
        }
        
        guard let retryCount = retriedRequests[url] else {
            retriedRequests[url] = 1
            completion(.retry)
            return
        }
        
        if retryCount < maxRetries { // check remaining retries available
            retriedRequests[url] = retryCount + 1
            completion(.retry)
        } else {
            removeCachedUrlRequest(url: url)
            completion(.doNotRetry)
        }
    }
    
    // removes requests completed
    private func removeCachedUrlRequest(url: String?) {
        guard let url = url else {
            return
        }
        retriedRequests.removeValue(forKey: url)
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        var urlRequest = urlRequest

        // make any changes urlRequest
        
        completion(.success(urlRequest))
    }
    
    
}

