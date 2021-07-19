//
//  UILabel+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UILabel {
    
    var safeText: String {
        return text.isNil ? "" : text!
    }
    
    func isTruncated() -> Bool {
        if numberOfLines == 0 { return false }
        
        let labelText = safeText as NSString
        
        let size = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = labelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font as Any], context: nil)
        
        let calculatedNumberOfLines = Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
        
        return calculatedNumberOfLines > numberOfLines
            
    }
}

