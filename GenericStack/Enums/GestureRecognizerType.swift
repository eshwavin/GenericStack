//
//  GestureRecognizerType.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 23/10/20.
//  Copyright © 2020 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

enum GestureRecognizerType {
    case tap
    case pinch
    case rotation
    case swipe
    case pan
    case screenEdgePan
    case longPress
    case custom(recognizer: UIGestureRecognizer)
}
