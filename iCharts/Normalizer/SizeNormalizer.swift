//
//  SizeNormalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

// TODO: rename as scaleToFill
final class SizeNormalizer: Normalizer {
    
    func unsafeNormalize(line: Line, args: NormalizationArgs) -> Line {
        let size = args.targetSize
        let xs = normalize(xs: line.points.xs, args: args)
        let ys = normalize(vector: line.points.ys, side: size.height, max: args.maxPoint.y)
            .map { size.height - $0 }
        
        return Line(title: line.title, xs: xs, ys: ys, color: line.color)
    }
    
    /// Xmin = X0, X ~> X' = { x' in [0, width] }
    private func normalize(xs: Vector, args: NormalizationArgs) -> Vector {
        let normalizedXS = normalize(xs: xs, min: args.minPoint.x)
        let max = args.maxPoint.x - args.minPoint.x
        return normalize(vector: normalizedXS, side: args.targetSize.width, max: max)
    }
    
    /// A ~> A' = { a' in [0, s] }, a' = a / ((Amax - Amin) / side)
    private func normalize(vector: Vector, side: CGFloat, max: CGFloat? = nil) -> Vector {
        guard let max = max ?? vector.max() else {
            return vector
        }
        
        return vector.factored(by: max / side)
    }
}


