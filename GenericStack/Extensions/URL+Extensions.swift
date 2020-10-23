//
//  URL+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 22/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension URL {
    
    func withPathParameters(_ parameters: [String: Any]?) -> URL {
        
        guard var urlString = self.absoluteString.removingPercentEncoding, let parameters = parameters else {
            return self
        }
        
        for parameter in parameters {
            urlString = urlString.replacingOccurrences(of: "{\(parameter.key)}", with: "\(parameter.value)")
        }
        
        guard let url = URL(string: urlString) else { return self }
        return url
        
    }
    
}
