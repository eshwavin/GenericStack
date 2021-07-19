//
//  CustomFont.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol CustomFontProtocol {
    func scaledFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont?
}

final class CustomFont: CustomFontProtocol {
    private struct FontDescription: Decodable {
        let fontSize: CGFloat
        let fontName: String
    }
    
    private typealias StyleDictionary = [UIFont.TextStyle.RawValue: FontDescription]
    private var styleDictionary: StyleDictionary?
    
    /// Create a `ScaledFont`
    ///
    /// - Parameter fontName: Name of a plist file (without the extension)
    ///   that contains the style dictionary used to
    ///   scale fonts for each text style.
    ///   Defaults to fontName in GlobalConstants.UIConstants.fontName
    /// - Parameter bundle: Bundle containing the plist file.
    ///   Defaults to the main bundle.
    init(fontName: String, in bundle: Bundle = Bundle.main) {
        if let url = bundle.url(forResource: fontName, withExtension: "plist"),
           let data = try? Data(contentsOf: url) {
            let decoder = PropertyListDecoder()
            styleDictionary = try? decoder.decode(StyleDictionary.self, from: data)
        }
    }
    
    /// Get the scaled font for the given text style using the
    /// style dictionary supplied at initialization.
    ///
    /// - Parameter textStyle: The `UIFontTextStyle` for the
    ///   font.
    /// - Returns: A `UIFont` of the custom font that has been
    ///   scaled for the users currently selected preferred
    ///   text size.
    ///
    /// - Note: If the style dictionary does not have
    ///   a font for this text style the default preferred
    ///   font is returned.
    func scaledFont(forTextStyle textStyle: UIFont.TextStyle) -> UIFont {
        guard let fontDescription = styleDictionary?[textStyle.rawValue],
              let font = UIFont(name: fontDescription.fontName, size: fontDescription.fontSize) else {
            return UIFont.preferredFont(forTextStyle: textStyle)
        }
        
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        return fontMetrics.scaledFont(for: font)
    }
    
    /// Get the base font for the given text style using the
    /// style dictionary supplied at initialization.
    ///
    /// - Parameter textStyle: The `UIFontTextStyle` for the
    ///   font.
    /// - Returns: A `UIFont` of the custom font that has been
    ///   scaled for the users currently selected preferred
    ///   text size. If the style dictionary does not have
    ///   a font for this text style nil is returned
    func font(forTextStyle textStyle: UIFont.TextStyle) -> UIFont? {
        guard let fontDescription = styleDictionary?[textStyle.rawValue],
              let font = UIFont(name: fontDescription.fontName, size: fontDescription.fontSize) else {
            return nil
        }
        
        return font
    }

}

