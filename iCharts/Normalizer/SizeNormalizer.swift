//
//  SizeNormalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

final class SizeNormalizer: Normalizer {
    
    private let size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func normalize(chart: Chart) -> Chart {
        var chart = chart
        
        chart.lines = chart.lines.map { line in
            let xs = normalize(xs: line.points.xs, width: size.width)
            let ys = normalize(vector: line.points.ys, side: size.height).map { size.height - $0 }
            
            return Line(xs: xs, ys: ys, color: line.color)
        }
        
        return chart
    }
    
    /// Xmin = X0, X ~> X' = { x' in [0, width] }
    private func normalize(xs: Vector, width: CGFloat) -> Vector {
        let normalizedXS = normalize(xs: xs)
        return normalize(vector: normalizedXS, side: width, max: normalizedXS.last)
    }
    
    /// A ~> A' = { a' in [0, s] }, a' = a / ((Amax - Amin) / side)
    private func normalize(vector: Vector, side: CGFloat, max: CGFloat? = nil) -> Vector {
        guard let max = max ?? vector.max() else {
            return vector
        }
        
        return vector.factored(by: max / side)
    }
}


