//
//  UIResponder+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

// MARK:- UIResponder+ViewController
extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

// MARK:- UIResponder+Scene

extension UIResponder {
    @objc var scene: UIScene? {
        return nil
    }
}

extension UIScene {
    @objc override var scene: UIScene? {
        return self
    }
}

extension UIView {
    @objc override var scene: UIScene? {
        if let window = self.window {
            return window.windowScene
        } else {
            return self.next?.scene
        }
    }
}

extension UIViewController {
    @objc override var scene: UIScene? {
        // Try walking the responder chain
        var res = self.next?.scene
        if (res == nil) {
            // That didn't work. Try asking my parent view controller
            res = self.parent?.scene
        }
        if (res == nil) {
            // That didn't work. Try asking my presenting view controller
            res = self.presentingViewController?.scene
        }

        return res
    }
}

