//
//  UINavigationController+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 26/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func popToViewController<T: UIViewController>(_ type: T.Type) {
        guard let viewController = viewControllers.first(where: { $0 is T }) else { return }
        popToViewController(viewController, animated: true)
    }
    
}
