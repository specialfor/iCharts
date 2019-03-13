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
    
    func unsafeNormalize(line: Line) -> Line {
        let (xs, factor) = normalize(xs: line.points.xs)
        let ys = line.points.ys.factored(by: factor)
        
        return Line(xs: xs, ys: ys, color: line.color)
    }
    
    private func normalize(xs: Vector) -> (xs: Vector, factor: CGFloat) {
        let xs: Vector = normalize(xs: xs)
        let factor = minDelta(in: xs) / length
        return (xs.factored(by: factor), factor)
    }
    
    private func minDelta(in vector: Vector) -> CGFloat {
        let deltas: [CGFloat] = (0..<(vector.count - 1)).reduce(into: []) { result, index in
            let delta = abs(vector[index] - vector[index + 1])
            result.append(delta)
        }

        return deltas.min()!
    }
}
