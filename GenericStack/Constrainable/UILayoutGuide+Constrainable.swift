//
//  UILayoutGuide+Constrainable.swift
//  GenericStack
//
//  Created by Vinayak Eshwa on 26/07/23.
//  Copyright © 2023 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UILayoutGuide: Constrainable {
    public var container: Constrainable? {
        return owningView
    }
    
    public var translatesAutoresizingMaskIntoConstraints: Bool {
        get {
            return false
        }
        set {
            return
        }
    }
    
    public var optionalSafeAreaLayoutGuide: UILayoutGuide? {
        return nil
    }
}

