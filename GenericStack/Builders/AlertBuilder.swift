//
//  AlertBuilder.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

class AlertBuilder {
    
    private var alertController: UIAlertController
    
    public init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style) {
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
    }
    
    public func setPopoverPresentationProperties(sourceView: UIView? = nil, sourceRect: CGRect? = nil, barButtonItem: UIBarButtonItem? = nil, permittedArrowDirections: UIPopoverArrowDirection? = nil) -> Self {
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            if let view = sourceView {
                popoverPresentationController.sourceView = view
            }
            if let rect = sourceRect {
                popoverPresentationController.sourceRect = rect
            }
            if let item = barButtonItem {
                popoverPresentationController.barButtonItem = item
            }
            if let directions = permittedArrowDirections {
                popoverPresentationController.permittedArrowDirections = directions
            }
        }
        
        return self
        
    }
    
    public func addAction(title: String = "", style: UIAlertAction.Style = .default, handler: (() -> ())? = {}) -> Self {
        alertController.addAction(UIAlertAction(title: title, style: style, handler: { _ in
            handler?()
        }))
        return self
    }
    
    public func build() -> UIAlertController {
        return alertController
    }
}

