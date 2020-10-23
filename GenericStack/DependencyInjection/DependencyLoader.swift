//
//  DependencyLoader.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Swinject

class DependencyLoader {
    
    static let instance: DependencyLoader = DependencyLoader()
    
    let container = Container()
    private let assembler: Assembler
    
    private init() {
        
        assembler = Assembler([
            ViewControllerAssembly(),
            PresenterAssembly(),
            RepositoryAssembly(),
            NetworkAssembly(),
            ServiceAssembly()
        ], container: container)
        
        InjectSettings.resolver = container
    
    }
    
}
