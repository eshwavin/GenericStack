//
//  Constrainable.swift
//  GenericStack
//
//  Created by Vinayak Eshwa on 26/07/23.
//  Copyright © 2023 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

protocol Constrainable: AnyObject {
    var container: Constrainable? { get }
    var translatesAutoresizingMaskIntoConstraints: Bool { get set }
    
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    
    var optionalSafeAreaLayoutGuide: UILayoutGuide? { get }
}

// MARK: - All Edges
extension Constrainable {
    
    @discardableResult func pin(edges: Edge..., to constrainable: Constrainable? = nil) -> [String: NSLayoutConstraint] {
        
        var constraints = [String: NSLayoutConstraint]()
        let constraintToConstrainable: Constrainable = getConstrainable(for: constrainable)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        for edge in edges {
            
            if constraintToConstrainable is UILayoutGuide,
               edge.isSafeAreaEdge {
                assertionFailure("Attempt to use UISafeAreaLayoutGuide related constraints on UILayoutGuide, causing access to safeAreaLayoutGuide of a UILayoutGuide. Attempting to restore by skipping setting these constraints.")
                continue
            }
            
            let constraint: NSLayoutConstraint?
            
            switch edge {
                
            // absolute: top
            case .safeAreaTop(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .top(let spacing):
                constraint = topAnchor.constraint(equalTo: constraintToConstrainable.topAnchor, constant: spacing)
                
            // absolute: bottom
            case .safeAreaBottom(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .bottom(let spacing):
                constraint = bottomAnchor.constraint(equalTo: constraintToConstrainable.bottomAnchor, constant: spacing)
                
            // absolute: leading
            case .safeAreaLeading(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .leading(let spacing):
                constraint = leadingAnchor.constraint(equalTo: constraintToConstrainable.leadingAnchor, constant: spacing)
                
            // absolute: trailing
            case .safeAreaTrailing(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .trailing(let spacing):
                constraint = trailingAnchor.constraint(equalTo: constraintToConstrainable.trailingAnchor, constant: spacing)
                
            // relative: top
            case .greaterThanSafeAreaTop(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .greaterThanTop(let spacing):
                constraint = topAnchor.constraint(greaterThanOrEqualTo: constraintToConstrainable.topAnchor, constant: spacing)
                
            // relative: bottom
            case .lessThanSafeAreaBottom(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .lessThanBottom(let spacing):
                constraint = bottomAnchor.constraint(lessThanOrEqualTo: constraintToConstrainable.bottomAnchor, constant: spacing)
                
                
            // relative: leading
            case .greaterThanSafeAreaLeading(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .greaterThanLeading(let spacing):
                constraint = leadingAnchor.constraint(greaterThanOrEqualTo: constraintToConstrainable.leadingAnchor, constant: spacing)
                
            // relative: trailing
            case .lessThanSafeAreaTrailing(let spacing):
                if let safeAreaLayoutGuide = constraintToConstrainable.optionalSafeAreaLayoutGuide {
                    constraint = trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: spacing)
                }
                else {
                    constraint = nil
                }
                
            case .lessThanTrailing(let spacing):
                constraint = trailingAnchor.constraint(lessThanOrEqualTo: constraintToConstrainable.trailingAnchor, constant: spacing)
            }
            
            if let constraint {
                constraint.isActive = true
                constraints[edge.rawValue] = constraint
            }
            
        }
        
        return constraints
    }
    
    @discardableResult func pinAllEdgesSafely(to view: UIView? = nil, withSpacing spacing: CGFloat = 0) -> [String: NSLayoutConstraint] {
        return pin(edges: .safeAreaTop(spacing: spacing), .safeAreaLeading(spacing: spacing), .safeAreaTrailing(spacing: -spacing), .safeAreaBottom(spacing: -spacing), to: view)
    }
    
    @discardableResult func pinAllEdges(to view: UIView? = nil, withSpacing spacing: CGFloat = 0) -> [String: NSLayoutConstraint] {
        return pin(edges: .top(spacing: spacing), .leading(spacing: spacing), .trailing(spacing: -spacing), .bottom(spacing: -spacing), to: view)
    }
    
}

// MARK: - Top
extension Constrainable {
    
    @discardableResult func pinTopToSafeArea(of view: UIView? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaTop(spacing: spacing)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinTop(to constrainable: Constrainable? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .top(spacing: spacing)
        return pinEdge(edge, to: constrainable)
        
    }
    
}

// MARK: - Bottom
extension Constrainable {
    
    @discardableResult func pinBottomToSafeArea(of view: UIView? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaBottom(spacing: spacing)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinBottom(to constrainable: Constrainable? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .bottom(spacing: spacing)
        return pinEdge(edge, to: constrainable)
    }
    
}

// MARK: - Leading
extension Constrainable {
    
    @discardableResult func pinLeadingToSafeArea(of view: UIView? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaLeading(spacing: spacing)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinLeading(to constrainable: Constrainable? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .leading(spacing: spacing)
        return pinEdge(edge, to: constrainable)
    }
    
}

// MARK: - Trailing
extension Constrainable {
    
    @discardableResult func pinTrailingToSafeArea(of view: UIView? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaTrailing(spacing: spacing)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinTrailing(to constrainable: Constrainable? = nil, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .trailing(spacing: spacing)
        return pinEdge(edge, to: constrainable)
    }
    
}

// MARK: - Other Vertical
extension Constrainable {
    
    @discardableResult func pinTopToBottom(of constrainable: Constrainable, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: constrainable.bottomAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinBottomToTop(of constrainable: Constrainable, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: constrainable.topAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinTopToCenterY(of constrainable: Constrainable, withOffset offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: constrainable.centerYAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinBottomToCenterY(of constrainable: Constrainable, withOffset offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: constrainable.centerYAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
}

// MARK: - Other Horizontal
extension Constrainable {
    
    @discardableResult func pinLeadingToTrailing(of constrainable: Constrainable, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: constrainable.trailingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinTrailingToLeading(of constrainable: Constrainable, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: constrainable.leadingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinLeadingToCenterX(of constrainable: Constrainable, withOffset offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: constrainable.centerXAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinTrailingToCenterX(of constrainable: Constrainable, withOffset offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: constrainable.centerXAnchor, constant: offset)
        constraint.isActive = true
        return constraint
    }
    
}

// MARK: - Center
extension Constrainable {
    
    @discardableResult func centerX(to constrainable: Constrainable? = nil, withOffset offset: CGFloat = 0) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToConstrainable: Constrainable = getConstrainable(for: constrainable)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        constraint = centerXAnchor.constraint(equalTo: constraintToConstrainable.centerXAnchor, constant: offset)
        
        constraint.isActive = true
        return constraint
        
    }
    
    @discardableResult func centerY(to constrainable: Constrainable? = nil, withOffset offset: CGFloat = 0) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToConstrainable: Constrainable = getConstrainable(for: constrainable)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        constraint = centerYAnchor.constraint(equalTo: constraintToConstrainable.centerYAnchor, constant: offset)
        
        constraint.isActive = true
        return constraint
        
    }
    
    @discardableResult func center(to view: UIView? = nil) -> [String: NSLayoutConstraint] {
        let centerXConstraint = centerX(to: view)
        let centerYConstraint = centerY(to: view)
        
        return [
            "centerX": centerXConstraint,
            "centerY": centerYConstraint
        ]
    }
}

// MARK: - Dimensions
extension Constrainable {
    
    // MARK: Height
    
    @discardableResult func constrainHeight(equalTo constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainHeightToSuperview(multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraintToConstrainable: Constrainable = getConstrainable(for: nil)
        return constrainHeight(to: constraintToConstrainable, multiplier: multiplier, constant: constant)
    }
    
    @discardableResult func constrainHeight(to constrainable: Constrainable, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToConstrainable: Constrainable = getConstrainable(for: constrainable)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        constraint = heightAnchor.constraint(equalTo: constraintToConstrainable.heightAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
        
    }
    
    @discardableResult func constrainHeight(greaterThanEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainHeight(lessThanEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: Width
    
    @discardableResult func constrainWidth(equalTo constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainWidthToSuperview(multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraintToConstrainable: Constrainable = getConstrainable(for: nil)
        return constrainWidth(to: constraintToConstrainable, multiplier: multiplier, constant: constant)
    }
    
    @discardableResult func constrainWidth(to constrainable: Constrainable, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToConstrainable: Constrainable = getConstrainable(for: constrainable)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        constraint = widthAnchor.constraint(equalTo: constraintToConstrainable.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
        
    }
    
    @discardableResult func constrainWidth(greaterThanEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainWidth(lessThanEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: Aspect Ratio
    
    /// Sets aspect ratio of the view
    /// - Parameter ratio: ratio in width / height
    /// - Returns: The constraint created
    @discardableResult func setAspectRatio(to ratio: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio)
        constraint.isActive = true
        return constraint
    }
    
}

// MARK: - Helpers
extension Constrainable {
    
    func pinEdge(_ edge: Edge, to constrainable: Constrainable? = nil) -> NSLayoutConstraint {
        return pin(edges: edge, to: constrainable)[edge.rawValue]!
    }
    
    private func getConstrainable(for targetConstrainable: Constrainable?) -> Constrainable {
        let constraintToConstrainable: Constrainable
        
        if let targetConstrainable {
            constraintToConstrainable = targetConstrainable
        } else {
            guard let container else {
                fatalError("Both targetConstrainable and container are nil")
            }
            constraintToConstrainable = container
        }
        
        return constraintToConstrainable
    }
    
}

