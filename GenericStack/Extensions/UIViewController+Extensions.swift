//
//  UIViewController+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 26/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

// MARK:- Presenting ViewControllers

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
    
    func present(_ viewController: UIViewController, requiresFullScreen: Bool = true, completion: (() -> ())? = nil) {
        viewController.modalPresentationStyle = requiresFullScreen ? .fullScreen : .automatic
        present(viewController, animated: true, completion: completion)
    }
    
}

// MARK:- Navigation Bar

extension UIViewController {
    func hideNavigationBar(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showNavigationBar(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func hideBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

// MARK:- Visibility

extension UIViewController {
    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
}

