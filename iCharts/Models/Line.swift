//
//  Line.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit.UIColor

public struct Line {
    let title: String
    let points: Points
    let color: UIColor
    
    public init(title: String, points: Points, color: UIColor) {
        self.title = title
        self.points = points
        self.color = color
    }
    
    public init(title: String, xs: [CGFloat], ys: [CGFloat], color: UIColor) {
        self.init(
            title: title,
            points: zipToPoints(xs, ys),
            color: color)
    }
}
