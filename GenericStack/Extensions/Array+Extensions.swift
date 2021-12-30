//
//  Array+Extensions.swift
//  GenericStack
//
//  Created by Srivinayak Chaitanya Eshwa on 20/07/21.
//  Copyright © 2021 Srivinayak Chaitanya Eshwa. All rights reserved.
//

import Foundation

extension Array {
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    
    @discardableResult mutating func removeIf(predicate: (Element) -> Bool) -> [Element] {
        var removedCount: Int = 0
        var removed: [Element] = []
        
        for (index,element) in self.enumerated() {
            if predicate(element) {
                removed.append(self.remove(at: index-removedCount))
                removedCount += 1
            }
        }
        
        return removed
    }
    
    public mutating func appendDistinct<S>(contentsOf newElements: S, where condition:@escaping (Element, Element) -> Bool) where S : Sequence, Element == S.Element {
        newElements.forEach { (item) in
            if !(self.contains(where: { (selfItem) -> Bool in
                return !condition(selfItem, item)
            })) {
                self.append(item)
            }
        }
    }
    
    mutating func remove(at indices: IndexSet) {
        indices
            .sorted(by: >)
            .forEach { rmIndex in
                self.remove(at: rmIndex)
            }
    }
    
    func indices(where predicate: (Element) -> Bool) -> [Int] {
        var result: [Int] = []
        for (index, element) in enumerated() {
            if predicate(element) {
                result.append(index)
            }
        }
        return result
    }
    
}
