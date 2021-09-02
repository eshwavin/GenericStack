//
//  File.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 02/09/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

final class File {
    
    let name: String
    let key: String
    let mimeType: MimeType
    let data: Data
    
    init(name: String, key: String, mimeType: MimeType, data: Data) {
        self.name = name
        self.key = key
        self.mimeType = mimeType
        self.data = data
    }
    
}
