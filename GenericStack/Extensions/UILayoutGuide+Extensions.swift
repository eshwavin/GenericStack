//
//  UILayoutGuide+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension UILayoutGuide {
    
    @discardableResult func pin(edges: Edge..., to view: UIView? = nil) -> [String: NSLayoutConstraint] {
        
        var constraints = [String: NSLayoutConstraint]()
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let owningView = owningView else { fatalError("Both view and superview are nil") }
            constraintToView = owningView
        }
        
        constraintToView.translatesAutoresizingMaskIntoConstraints = false
        
        for edge in edges {
            
            let constraint: NSLayoutConstraint
            
            switch edge {
            
            case .safeAreaTop(let padding):
                constraint = topAnchor.constraint(equalTo: constraintToView.safeAreaLayoutGuide.topAnchor, constant: padding)
            
            case .top(let padding):
                constraint = topAnchor.constraint(equalTo: constraintToView.topAnchor, constant: padding)
                
            case .safeAreaLeading(let padding):
                constraint = leadingAnchor.constraint(equalTo: constraintToView.safeAreaLayoutGuide.leadingAnchor, constant: padding)
            
            case .leading(let padding):
                constraint = leadingAnchor.constraint(equalTo: constraintToView.leadingAnchor, constant: padding)
                
            case .safeAreaTrailing(let padding):
                constraint = trailingAnchor.constraint(equalTo: constraintToView.safeAreaLayoutGuide.trailingAnchor, constant: padding)
            
            case .trailing(let padding):
                constraint = trailingAnchor.constraint(equalTo: constraintToView.trailingAnchor, constant: padding)
                
            case .lessThanTrailing(let padding):
                constraint = trailingAnchor.constraint(lessThanOrEqualTo: constraintToView.trailingAnchor, constant: padding)
                
            case .safeAreaBottom(let padding):
                constraint = bottomAnchor.constraint(equalTo: constraintToView.safeAreaLayoutGuide.bottomAnchor, constant: padding)
            
            case .bottom(let padding):
                constraint = bottomAnchor.constraint(equalTo: constraintToView.bottomAnchor, constant: padding)
            
            }
            
            constraint.isActive = true
            constraints[edge.rawValue] = constraint
            
        }
        
        return constraints
        
    }
    
    @discardableResult func pinAllEdgesSafely(to view: UIView? = nil, withPadding padding: CGFloat = 0) -> [String: NSLayoutConstraint] {
        return pin(edges: .safeAreaTop(padding: padding), .safeAreaLeading(padding: padding), .safeAreaTrailing(padding: padding), .safeAreaBottom(padding: padding), to: view)
    }

    @discardableResult func pinAllEdges(to view: UIView? = nil, withPadding padding: CGFloat = 0) -> [String: NSLayoutConstraint] {
        return pin(edges: .top(padding: padding), .leading(padding: padding), .trailing(padding: padding), .bottom(padding: padding), to: view)
    }
    
    @discardableResult func pinTopToSafeArea(of view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaTop(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinTop(to view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .top(padding: padding)
        return pinEdge(edge, to: view)
        
    }
    
    // MARK: Leading
    
    @discardableResult func pinLeadingToSafeArea(of view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaLeading(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinLeading(to view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .leading(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    // MARK: Trailing
    
    @discardableResult func pinTrailingToSafeArea(of view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaTrailing(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinTrailing(to view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .trailing(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    // MARK: Bottom
    
    @discardableResult func pinBottomToSafeArea(of view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .safeAreaBottom(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    @discardableResult func pinBottom(to view: UIView? = nil, withPadding padding: CGFloat) -> NSLayoutConstraint {
        let edge: Edge = .bottom(padding: padding)
        return pinEdge(edge, to: view)
    }
    
    // MARK: Other Horizontal

    @discardableResult func pinLeadingToTrailing(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint = leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinTrailingToLeading(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: Other Vertical
    
    @discardableResult func pinTopToBottom(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinBottomToTop(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: view.topAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }


    // MARK: Dimensions
    
    @discardableResult func constrainHeight(equalTo constant: CGFloat) -> NSLayoutConstraint {
        
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainHeight(equalTo constant: CGFloat, multiplier: CGFloat, to view: UIView? = nil) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let owningView = owningView else { fatalError("Both view and superview are nil") }
            constraintToView = owningView
        }
        
        constraintToView.translatesAutoresizingMaskIntoConstraints = false
        
        constraint = heightAnchor.constraint(equalTo: constraintToView.heightAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
        
    }
    
    @discardableResult func constrainHeight(equalTo constant: CGFloat, multiplier: CGFloat, to layoutGuide: UILayoutGuide) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint = heightAnchor.constraint(equalTo: layoutGuide.heightAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
    }
    
    @discardableResult func constrainWidth(equalTo constant: CGFloat) -> NSLayoutConstraint {
        
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainWidth(equalTo constant: CGFloat, multiplier: CGFloat, to view: UIView? = nil) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let owningView = owningView else { fatalError("Both view and superview are nil") }
            constraintToView = owningView
        }
        
        constraintToView.translatesAutoresizingMaskIntoConstraints = false
        
        constraint = widthAnchor.constraint(equalTo: constraintToView.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
        
    }
    
    @discardableResult func constrainWidth(equalTo constant: CGFloat,  multiplier: CGFloat, to layoutGuide: UILayoutGuide) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint = widthAnchor.constraint(equalTo: layoutGuide.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        
        return constraint
    }
    
    // MARK: Helper

    func pinEdge(_ edge: Edge, to view: UIView? = nil) -> NSLayoutConstraint {
        return pin(edges: edge, to: view)[edge.rawValue]!
    }
    
}
