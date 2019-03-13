//
//  Line.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit.UIColor

public struct Line {
    let points: Points
    let color: UIColor
    
    public init(points: Points, color: UIColor) {
        self.points = points
        self.color = color
    }
    
    public init(xs: [CGFloat], ys: [CGFloat], color: UIColor) {
        self.init(
            points: zipToPoints(xs, ys),
            color: color)
    }
}
