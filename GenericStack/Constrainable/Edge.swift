//
//  Edge.swift
//  GenericStack
//
//  Created by Vinayak Eshwa on 26/07/23.
//  Copyright © 2023 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

public enum Edge {
    case safeAreaTop(spacing: CGFloat)
    case top(spacing: CGFloat)
    case safeAreaBottom(spacing: CGFloat)
    case bottom(spacing: CGFloat)
    case safeAreaLeading(spacing: CGFloat)
    case leading(spacing: CGFloat)
    case safeAreaTrailing(spacing: CGFloat)
    case trailing(spacing: CGFloat)
    
    case greaterThanSafeAreaTop(spacing: CGFloat)
    case greaterThanTop(spacing: CGFloat)
    case lessThanSafeAreaBottom(spacing: CGFloat)
    case lessThanBottom(spacing: CGFloat)
    case greaterThanSafeAreaLeading(spacing: CGFloat)
    case greaterThanLeading(spacing: CGFloat)
    case lessThanSafeAreaTrailing(spacing: CGFloat)
    case lessThanTrailing(spacing: CGFloat)
    
    var rawValue: String {
        switch self {
        case .safeAreaTop:
            return "safeAreaTop"
        case .top:
            return "top"
        case .safeAreaBottom:
            return "safeAreaBottom"
        case .bottom:
            return "bottom"
        case .safeAreaLeading:
            return "safeAreaLeading"
        case .leading:
            return "leading"
        case .safeAreaTrailing:
            return "safeAreaTrailing"
        case .trailing:
            return "trailing"
            
        case .greaterThanSafeAreaTop:
            return "greaterThanSafeAreaTop"
        case .greaterThanTop:
            return "greaterThanTop"
        case .lessThanSafeAreaBottom:
            return "lessThanSafeAreaBottom"
        case .lessThanBottom:
            return "lessThanBottom"
        case .greaterThanSafeAreaLeading:
            return "greaterThanSafeAreaLeading"
        case .greaterThanLeading:
            return "greaterThanLeading"
        case .lessThanSafeAreaTrailing:
            return "lessThanSafeAreaTrailing"
        case .lessThanTrailing:
            return "lessThanTrailing"
        }
    }
    
    var isSafeAreaEdge: Bool {
        switch self {
        case .safeAreaTop, .safeAreaBottom, .safeAreaLeading, .safeAreaTrailing:
            return true
        case .greaterThanSafeAreaTop, .lessThanSafeAreaBottom, .greaterThanSafeAreaLeading, .lessThanSafeAreaTrailing:
            return true
        default:
            return false
        }
    }
}

