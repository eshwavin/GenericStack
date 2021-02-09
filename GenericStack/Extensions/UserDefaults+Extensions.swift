//
//  UserDefaults+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func clearAll() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        removePersistentDomain(forName: bundleIdentifier)
        synchronize()
    }
    
}

