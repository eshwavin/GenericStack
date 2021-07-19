//
//  NotificationCenter+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func postOnMainThread(name: NSNotification.Name, object: Any?, userInfo: [AnyHashable: Any]? = nil) {
        runOnMainThread {
            self.post(name: name, object: object, userInfo: userInfo)
        }
    }
}

