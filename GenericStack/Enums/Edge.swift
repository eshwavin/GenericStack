//
//  Edge.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

enum Edge {
    case safeAreaTop(padding: CGFloat)
    case top(padding: CGFloat)
    case safeAreaLeading(padding: CGFloat)
    case leading(padding: CGFloat)
    case safeAreaTrailing(padding: CGFloat)
    case trailing(padding: CGFloat)
    case safeAreaBottom(padding: CGFloat)
    case bottom(padding: CGFloat)
    
    var rawValue: String {
        switch self {
        case .safeAreaTop:
            return "safeAreaTop"
        case .top:
            return "top"
        case .safeAreaLeading:
            return "safeAreaLeading"
        case .leading:
            return "leading"
        case .safeAreaTrailing:
            return "safeAreaTrailing"
        case .trailing:
            return "trailing"
        case .safeAreaBottom:
            return "safeAreaBottom"
        case .bottom:
            return "bottom"
        }
    }
}

