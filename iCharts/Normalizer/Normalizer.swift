//
//  Normalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/12/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

typealias Chart = ChartView.Props.LinearChart
typealias Vector = ChartView.Props.Vector
typealias Line = Chart.Line

protocol Normalizer {
    func normalize(chart: Chart) -> Chart
}

extension Normalizer {
    
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

