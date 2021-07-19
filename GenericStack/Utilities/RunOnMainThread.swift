//
//  RunOnMainThread.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

import Foundation

func runOnMainThread(block: @escaping () -> ()) {
    DispatchQueue.main.async {
        block()
    }
}

func runOnMainThreadAfter(deadline: DispatchTime, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: deadline) {
        block()
    }
}
