//
//  ChartNormalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/12/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

final class ChartNormalizer {
    typealias Chart = ChartView.Props.LinearChart
    typealias Vector = ChartView.Props.Vector
    typealias Line = Chart.Line
    
    func normalizer(chart: Chart, size: CGSize) -> Chart {
        var chart = chart
        
        chart.xs = normalize(xs: chart.xs, width: size.width)
        
        chart.lines = chart.lines.map { line in
            let ys = normalize(vector: line.ys, side: size.height).map { size.height - $0 }
            return Line(ys: ys, color: line.color)
        }
        
        return chart
    }
    
    /// Xmin = X0, X ~> X' = { x' in [0, width] }
    private func normalize(xs: Vector, width: CGFloat) -> Vector {
        guard let min = xs.first else {
            return xs
        }
        
        let normalizedXS = xs.map { $0 / min }
        
        return normalize(vector: normalizedXS, side: width, max: normalizedXS.last)
    }
    
    /// A ~> A' = { a' in [0, s] }, a' = a / ((Amax - Amin) / side)
    private func normalize(vector: Vector, side: CGFloat, max: CGFloat? = nil) -> Vector {
        guard let max = max ?? vector.max() else {
            return vector
        }
        
        let chartSide = max
        let factor = chartSide / side
        
        return vector.map { $0 / factor }
    }
}
