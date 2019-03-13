//
//  Normalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/12/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

typealias Chart = ChartView.Props.LinearChart


protocol Normalizer {
    func unsafeNormalize(line: Line) -> Line
}

extension Normalizer {
    
    func normalize(chart: Chart) -> Chart {
        var chart = chart
        
        chart.lines = chart.lines.map(normalize(line:))
        return chart
    }
    
    func normalize(line: Line) -> Line {
        guard !line.points.isEmpty else {
            return line
        }
        
        return unsafeNormalize(line: line)
    }
    
    /// Xmin = X0, X ~> X' = { x' in [0, C] }
    func normalize(xs: Vector, after closure: ((CGFloat) -> CGFloat)? = nil) -> Vector {
        guard let min = xs.first else {
            return xs
        }
        
        var normalizedXS = xs.map { $0 / min - 1 }
        
        if let closure = closure {
            normalizedXS = normalizedXS.map(closure)
        }
        
        return normalizedXS
    }
}

