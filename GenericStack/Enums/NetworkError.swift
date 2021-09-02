//
//  NetworkError.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    
    case cancelled
    case noInternetConnection
    case invalidData
    case forbidden
    case unauthorized
    case internalServerError(code: Int)
    case unknown(description: String?)
    
    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "The network request was cancelled"
        case .noInternetConnection:
            return "No internet connection"
        case .invalidData:
            return "Something went wrong"
        case .forbidden:
            return "Action is forbidden. Please contact support"
        case .unauthorized:
            return "An unauthorized action occured. Please contact support"
        case .internalServerError:
            return "Internal server error. Please contact support"
        case .unknown:
            return "Some unknown error occured. Please contact support"
        }
    }
    
    var rawValue: Int {
        switch self {
        case .cancelled:
            return -999
        case .noInternetConnection:
            return -1009
        case .invalidData:
            return 1000
        case .forbidden:
            return 403
        case .unauthorized:
            return 401
        case .internalServerError(let code):
            return code
        case .unknown:
            return -1
        }
    }
    
}
