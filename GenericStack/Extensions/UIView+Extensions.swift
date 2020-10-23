//
//  UIView+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 21/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

// MARK:- Views styled with Nibs

extension UIView {
    
    static var nib: UINib {
        return UINib(nibName: self.className, bundle: nil)
    }
    
    static func loadFromNib(with owner: Any? = nil) -> Self {
        guard let view = Self.nib.instantiate(withOwner: owner, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
    
}

// MARK:- Activity Indicator

extension UIView {
    
    func showActivityIndicator(allowingUserInteraction: Bool) {
        
    }
    
    func hideActivityIndicator() {
        
    }
}

// MARK:- Constraint Related Functions

extension UIView {
    
    // MARK: All Edges
    
    @discardableResult func pin(edges: Edge..., toView view: UIView? = nil) -> [String: NSLayoutConstraint] {
        
        var constraints = [String: NSLayoutConstraint]()
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let superview = superview else { fatalError("Both view and superview are nil") }
            constraintToView = superview
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
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
    
    
    @discardableResult func pinAllEdgesSafely(to view: UIView? = nil, withPadding padding: CGFloat) -> [String: NSLayoutConstraint] {
        return pin(edges: .safeAreaTop(padding: padding), .safeAreaLeading(padding: padding), .safeAreaTrailing(padding: padding), .safeAreaBottom(padding: padding), toView: view)
    }
    
    @discardableResult func pinAllEdges(to view: UIView? = nil, withPadding padding: CGFloat) -> [String: NSLayoutConstraint] {
        return pin(edges: .top(padding: padding), .leading(padding: padding), .trailing(padding: padding), .bottom(padding: padding), toView: view)
    }
    
    // MARK: Top
    
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
    
    // MARK: Other Vertical
    
    @discardableResult func pinTopToBottom(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let constraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinBottomToTop(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let constraint = bottomAnchor.constraint(equalTo: view.topAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainTopToCenterY(of view: UIView, withConstant constant: CGFloat) -> NSLayoutConstraint {
        let constraint = topAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainBottomToCenterY(of view: UIView, withConstant constant: CGFloat) -> NSLayoutConstraint {
        let constraint = bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: Other Horizontal
    
    @discardableResult func pinLeadingToTrailing(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let constraint = leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func pinTrailingToLeading(of view: UIView, withSpacing spacing: CGFloat) -> NSLayoutConstraint {
        let constraint = trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacing)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainLeadingToCenterX(of view: UIView, withConstant constant: CGFloat) -> NSLayoutConstraint {
        let constraint = leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constrainTrailingToCenterX(of view: UIView, withConstant constant: CGFloat) -> NSLayoutConstraint {
        let constraint = bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    // MARK: Dimensions
    
    @discardableResult func constrainHeight(equalTo constant: CGFloat) -> NSLayoutConstraint {
        let constraint = heightAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constraintHeight(equalTo constant: CGFloat = 0, multiplier: CGFloat,toView view: UIView? = nil) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let superview = superview else { fatalError("Both view and superview are nil") }
            constraintToView = superview
        }
        
        constraint = heightAnchor.constraint(equalTo: constraintToView.heightAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
        
    }
    
    @discardableResult func constrainWidth(equalTo constant: CGFloat) -> NSLayoutConstraint {
        let constraint = widthAnchor.constraint(equalToConstant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult func constraintWidth(equalTo constant: CGFloat = 0, multiplier: CGFloat,toView view: UIView? = nil) -> NSLayoutConstraint {
        
        let constraint: NSLayoutConstraint
        let constraintToView: UIView
        
        if let view = view {
            constraintToView = view
        } else {
            guard let superview = superview else { fatalError("Both view and superview are nil") }
            constraintToView = superview
        }
        
        constraint = widthAnchor.constraint(equalTo: constraintToView.widthAnchor, multiplier: multiplier, constant: constant)
        constraint.isActive = true
        return constraint
        
    }
    
}

private extension UIView {
    func pinEdge(_ edge: Edge, to view: UIView? = nil) -> NSLayoutConstraint {
        return pin(edges: edge, toView: view)[edge.rawValue]!
    }
}

// MARK:-  Gesture Recognizers

extension UIView {
    
    @discardableResult func addGestureRecognizer(ofType type: String, action: Selector) -> UIGestureRecognizer {
        
        return UIGestureRecognizer()
        
    }
    
}
