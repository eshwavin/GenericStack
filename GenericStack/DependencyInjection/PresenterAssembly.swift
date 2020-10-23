//
//  PresenterAssembly.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation
import Swinject

class PresenterAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(HomeViewPresenterProtocol.self) { _ in
            return HomeViewPresenter()
        }
        
    }
    
}
