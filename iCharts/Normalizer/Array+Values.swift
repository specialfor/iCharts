//
//  Array+Values.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension Array {
    
    func values<T>(_ getter: (Element) -> T) -> [T] {
        return map(getter)
    }
    
    func values<T>(keyPath: KeyPath<Element, T>) -> [T] {
        return map { element in
            return element[keyPath: keyPath]
        }
    }
}
