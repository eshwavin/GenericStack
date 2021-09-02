//
//  NetworkAssembly.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Swinject

class NetworkAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(NetworkHandlerProtocol.self) { _ in
            return NetworkHandler()
        }
        
    }
    
}
