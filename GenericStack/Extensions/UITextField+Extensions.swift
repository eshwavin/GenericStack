//
//  UITextField+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UITextField {
    var unsafeText: String? {
        return text == "" ? nil : text
    }
    
    var safeText: String {
        return text.isNil ? "" : text!
    }
    
    func addDoneButtonToAccessoryView() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resignFirstResponder))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.setItems([spacer, button], animated: true)
        inputAccessoryView = toolbar
    }
    
}

