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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.restorationIdentifier = "activityIndicator"
            self.addSubview(activityIndicator)
            activityIndicator.center()
            activityIndicator.constrainHeightToSuperview()
            activityIndicator.setAspectRatio(to: 1)
            activityIndicator.startAnimating()
            self.isUserInteractionEnabled = allowingUserInteraction
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for subview in self.subviews where subview.restorationIdentifier == "activityIndicator" {
                guard let activityIndicator = subview as? UIActivityIndicatorView else { return }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                self.isUserInteractionEnabled = true
            }
        }
    }
}

// MARK:-  Gesture Recognizers

extension UIView {
    
    @discardableResult func addGestureRecognizer(ofType type: String, action: Selector) -> UIGestureRecognizer {
        
        return UIGestureRecognizer()
        
    }
    
}

// MARK:- View Layer

extension UIView {
    
    func roundCorners(with cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func roundSomeCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func round() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.masksToBounds = true
    }
    
    func addBorder(with color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func removeBorder() {
        layer.borderColor = nil
        layer.borderWidth = 0
    }
    
    @discardableResult func addDashedBorder(withPattern pattern: [NSNumber], color: UIColor, radius: CGFloat, width: CGFloat) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.lineWidth = width
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        layer.addSublayer(borderLayer)
        return borderLayer
    }
}

// MARK:- Animations

extension UIView {
    func fadeIn(in duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
            
        },
        completion: { (value: Bool) in
            if let complete = onCompletion { complete() }
        })
    }

    func fadeOut(in duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
            
        },
        completion: { [weak self] (value: Bool) in
            self?.isHidden = true
            if let complete = onCompletion { complete() }
        })
    }
    
    func pulse(with duration: TimeInterval, completionHandler: CAAnimation.CAAnimationBlockCallback? = nil) {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 0.9
        pulse.autoreverses = true
        pulse.initialVelocity = 0.5
        pulse.repeatCount = Float(Int(duration / 0.8))
        pulse.damping = 0.8
        if let completionHandler = completionHandler {
            pulse.completionBlock(callback: completionHandler)
        }
        layer.add(pulse, forKey: "pulse")
    }
}

// MARK:- UIView as Image

extension UIView {
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }

}
