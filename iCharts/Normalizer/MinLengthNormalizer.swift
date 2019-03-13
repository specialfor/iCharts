//
//  MinLengthNormalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

final class MinLengthNormalizer: Normalizer {
    
    private let length: CGFloat
    
    init(length: CGFloat) {
        self.length = length
    }
    
    func normalize(chart: Chart) -> Chart {
//        guard !chart.xs.isEmpty else {
//            return chart
//        }
//
//        var chart = chart
//
//        var xs = normalize(xs: chart.xs)
//
//        let factor = minDelta(in: xs) / length
//        xs = xs.factored(by: factor)
//
//        chart.lines = chart.lines.map { line in
//            let ys = line.ys.factored(by: factor)
//            return Line(ys: ys, color: line.color)
//        }
//
        return chart
    }
//
//    private func minDelta(in vector: Vector) -> CGFloat {
//        let deltas: [CGFloat] = (0..<(vector.count - 1)).reduce(into: []) { result, index in
//            let delta = abs(vector[index] - vector[index + 1])
//            result.append(delta)
//        }
//
//        return deltas.min()!
//    }
}
