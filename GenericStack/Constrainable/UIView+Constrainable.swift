//
//  UIView+Constrainable.swift
//  GenericStack
//
//  Created by Vinayak Eshwa on 26/07/23.
//  Copyright © 2023 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UIView: Constrainable {
    var container: Constrainable? {
        return superview
    }
    
    var optionalSafeAreaLayoutGuide: UILayoutGuide? {
        return safeAreaLayoutGuide
    }
}

extension UIView {
    func addConstrainable(_ constrainable: Constrainable) {
        if let view = constrainable as? UIView {
            addSubview(view)
        }
        else if let layoutGuide = constrainable as? UILayoutGuide {
            addLayoutGuide(layoutGuide)
        }
    }
}
