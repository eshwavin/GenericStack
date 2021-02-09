//
//  CAAnimation+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 09/02/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import UIKit

extension CAAnimation {
    
    typealias CAAnimationBlockCallback = (CAAnimation, Bool) -> ();

    final private class CAAnimationBlockCallbackDelegate: NSObject, CAAnimationDelegate {
       var onStartCallback: CAAnimationBlockCallback?
       var onCompleteCallback: CAAnimationBlockCallback?

       func animationDidStart(_ anim: CAAnimation) {
          if let startHandler = onStartCallback {
             startHandler(anim, true)
          }
       }

       func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
          if let completionHandler = onCompleteCallback {
             completionHandler(anim, flag);
          }
       }
    }
    
   // See if there is already a CAAnimationDelegate handling this animation
   // If there is, add onStart to it, if not create one
   func startBlock(callback: @escaping CAAnimationBlockCallback) {
      if let myDelegate = self.delegate as? CAAnimationBlockCallbackDelegate {
         myDelegate.onStartCallback = callback;
      } else {
         let callbackDelegate = CAAnimationBlockCallbackDelegate()
         callbackDelegate.onStartCallback = callback
         self.delegate = callbackDelegate
      }
   }

   // See if there is already a CAAnimationDelegate handling this animation
   // If there is, add onCompletion to it, if not create one
   func completionBlock(callback: @escaping CAAnimationBlockCallback) {
      if let myDelegate = self.delegate as? CAAnimationBlockCallbackDelegate {
         myDelegate.onCompleteCallback = callback
      } else {
         let callbackDelegate = CAAnimationBlockCallbackDelegate()
         callbackDelegate.onCompleteCallback = callback
         self.delegate = callbackDelegate
      }
   }
}

