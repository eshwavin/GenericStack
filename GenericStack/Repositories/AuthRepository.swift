//
//  AuthRepository.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

protocol AuthRepositoryProtocol {
    func login(parameters: Encodable, completionHandler: @escaping (Result<User, Error>) -> ())
}

class AuthRepository: AuthRepositoryProtocol {

    @Inject private var networkHandler: NetworkHandlerProtocol

    func login(parameters: Encodable, completionHandler: @escaping (Result<User, Error>) -> ()) {
        networkHandler.request(AuthRouter.login(parameters: parameters)).decoded(toType: User.self).observe(with: completionHandler)
    }
}
