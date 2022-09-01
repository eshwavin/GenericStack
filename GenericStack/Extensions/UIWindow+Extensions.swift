//
//  UIWindow+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UIWindow {
    func topViewController(controller: UIViewController? = nil, shouldConsiderChildViewControllers: Bool = false) -> UIViewController? {
        
        var controller = controller
        
        if controller == nil {
            controller = rootViewController
        }
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController, shouldConsiderChildViewControllers: shouldConsiderChildViewControllers)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected, shouldConsiderChildViewControllers: shouldConsiderChildViewControllers)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented, shouldConsiderChildViewControllers: shouldConsiderChildViewControllers)
        }
        if shouldConsiderChildViewControllers, let childViewController = controller?.children.first {
            return topViewController(controller: childViewController, shouldConsiderChildViewControllers: shouldConsiderChildViewControllers)
        }
        
        return controller
    }

}

