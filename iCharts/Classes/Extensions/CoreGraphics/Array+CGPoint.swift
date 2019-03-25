//
//  Array+CGPoint.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

extension Array where Element == CGPoint {
    
    var xs: [CGFloat] {
        return values(keyPath: \CGPoint.x)
    }
    
    var ys: [CGFloat] {
        return values(keyPath: \CGPoint.y)
    }
}
