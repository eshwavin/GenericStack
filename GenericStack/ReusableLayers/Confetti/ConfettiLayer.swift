//
//  ConfettiLayer.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

final class ConfettiLayer: CAEmitterLayer {
    
    private lazy var confettiTypes: [ConfettiType] = {
        let confettiColors: [UIColor] = [
            .rgba(red: 149, green: 58, blue: 255),
            .rgba(red: 255, green: 195, blue: 41),
            .rgba(red: 255, green: 101, blue: 26),
            .rgba(red: 123, green: 92, blue: 255),
            .rgba(red: 76, green: 126, blue: 255),
            .rgba(red: 71, green: 192, blue: 255),
            .rgba(red: 255, green: 47, blue: 39),
            .rgba(red: 255, green: 91, blue: 134),
            .rgba(red: 233, green: 122, blue: 208),
            ]
        
        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    private lazy var confettiCells: [CAEmitterCell] = {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            
            cell.beginTime = 0.1
            cell.birthRate = 10
            cell.contents = confettiType.image?.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 100
            cell.yAcceleration = 150
            
            
            // undocumented behaviour
            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
            
            
            return cell
        }
    }()
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    
    private func setup() {
        emitterCells = confettiCells
        emitterShape = .rectangle
        preservesDepth = true
        birthRate = 0
        beginTime = CACurrentMediaTime()
    }
    
    func addBirthRateAnimation() {
        let animation = CABasicAnimation(keyPath: "birthRate")
        animation.duration = 3
        animation.fromValue = 1
        animation.toValue = 0
        
        add(animation, forKey: "birthRate")
    }
}

