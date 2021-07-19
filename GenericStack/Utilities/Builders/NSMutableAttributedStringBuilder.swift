//
//  NSMutableAttributedStringBuilder.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

final class NSMutableAttributedStringBuilder {
    
    private let attributedString: NSMutableAttributedString
    
    init(string: String) {
        self.attributedString = NSMutableAttributedString(string: string)
    }
    
    func underline(with style: NSUnderlineStyle, inRangeOf string: String? = nil) -> Self {
        let range = rangeOf(string: string)
        return underline(with: style, inRange: range)
    }
    
    func underline(with style: NSUnderlineStyle, inRange range: NSRange) -> Self {
        attributedString.addAttributes([.underlineStyle: style.rawValue], range: range)
        return self
    }
    
    func addColor(with color: UIColor, inRangeOf string: String? = nil) -> Self {
        let range = rangeOf(string: string)
        return addColor(with: color, inRange: range)
    }
    
    func addColor(with color: UIColor, inRange range: NSRange) -> Self {
        attributedString.addAttributes([.foregroundColor: color], range: range)
        return self
    }
    
    func setFont(to font: UIFont?, inRangeOf string: String? = nil) -> Self {
        let range = rangeOf(string: string)
        return setFont(to: font, inRange: range)
    }
    
    func setFont(to font: UIFont?, inRange range: NSRange) -> Self {
        if let font = font {
            attributedString.addAttributes([.font: font], range: range)
        }
        return self
    }
    
    func append(_ attributedString: NSAttributedString) -> Self {
        self.attributedString.append(attributedString)
        return self
    }
    
    func append(_ string: String) -> Self {
        attributedString.append(NSAttributedString(string: string))
        return self
    }
    
    private func rangeOf(string: String?) -> NSRange {
        if let string = string {
//            return (self.attributedString.string as NSString).localizedStandardRange(of: string)
            return (attributedString.string as NSString).range(of: string)
        } else {
            return NSRange(location: 0, length: attributedString.length)
        }
    }
    
    func build() -> NSMutableAttributedString {
        return attributedString
    }
 
}

