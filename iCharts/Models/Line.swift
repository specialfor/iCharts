//
//  Line.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit.UIColor

public struct Line {
    public let title: String
    public var points: Points
    public let color: UIColor
    public var isHidden: Bool
    
    public init(title: String, points: Points, color: UIColor, isHidden: Bool = false) {
        self.title = title
        self.points = points
        self.color = color
        self.isHidden = isHidden
    }
    
    public init(title: String, xs: [CGFloat], ys: [CGFloat], color: UIColor, isHidden: Bool = false) {
        self.init(
            title: title,
            points: zipToPoints(xs, ys),
            color: color,
            isHidden: isHidden)
    }
}
