//
//  CountdownProtocol.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

protocol CountdownProtocol: AnyObject {
    var timer: Timer? { get set }
    func startTimer(withTimeInterval interval: TimeInterval)
    func invalidateTimer()
    func tick()
}

extension CountdownProtocol {
    
    func startTimer(withTimeInterval interval: TimeInterval = 1.0) {
        invalidateTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}

