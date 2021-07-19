//
//  String+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension String {
    
    static var blankSpace: String = "\u{00a0}"
    
    func getDate(with format: String, timeZone: TimeZone?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }
    
    func toDouble() -> Double {
        return Double(self) ?? 0
    }
    
    func toInt() -> Int {
        return Int(self) ?? 0
    }
    
    func asDictionary() throws -> [String: Any]? {
        return try JSONSerialization.jsonObject(with: data(using: .utf8)!, options: .allowFragments) as? [String: Any]
    }
    
    func getHTMLFormattedString() -> NSMutableAttributedString {
        
        guard let data = data(using: String.Encoding.unicode, allowLossyConversion: true),
              let attributedString: NSMutableAttributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
        else {
            return NSMutableAttributedString(string: "")
        }
        
        return attributedString
        
    }
    
    func firstWord() -> String? {
        return components(separatedBy: " ").first
    }
    
    func getNumberOfLines(inSize size: CGSize, usingFont font: UIFont) -> Int {
        let textSize = (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font as Any], context: nil)
        return Int(ceil(CGFloat(textSize.height) / font.lineHeight))
    }
    
    static func *(rhs: String, lhs: Int) -> String {
        return String(repeating: rhs, count: lhs)
    }
    
    func estimatedFrame(with font: UIFont, in size: CGSize) -> CGRect {
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: font], context: nil)
    }
    
    func trimmingWhitespacesAndNewlines() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
