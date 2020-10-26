//
//  UIViewController+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 26/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentModally(_ viewController: UIViewController, completion: (() -> ())? = nil) {
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .coverVertical
        present(viewController, animated: true, completion: completion)
    }
    
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func popTo<T: UIViewController>(_ type: T.Type) {
        navigationController?.popToViewController(type)
    }
    
    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
