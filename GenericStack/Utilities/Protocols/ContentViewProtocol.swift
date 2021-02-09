//
//  ContentViewProtocol.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol ContentViewProtocol {
    var contentView: UIView { get }
}

extension ContentViewProtocol where Self: UIView {
    func addShadow(withCornerRadius cornerRadius: CGFloat) {
        contentView.roundCorners(with: cornerRadius)
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = UIColor.systemBackground.cgColor
        layer.shadowColor = UIColor.systemGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

