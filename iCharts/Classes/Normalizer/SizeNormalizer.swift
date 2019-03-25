//
//  SizeNormalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

final class SizeNormalizer: Normalizer {
    
    let isInFullSize: Bool
    let verticalInset: CGFloat
    
    init(isInFullSize: Bool, verticalInset: CGFloat) {
        self.isInFullSize = isInFullSize
        self.verticalInset = verticalInset
    }
    
    func unsafeNormalize(line: Line, args: NormalizationArgs) -> Line {
        var line = line
        let (extendedLine, index) = extend(line: line)
        line = extendedLine
        
        let xs = normalize(xs: line.points.xs, args: args)
        let ys = normalize(ys: line.points.ys, args: args)

        line.points = zipToPoints(xs, ys)
        line = narrow(line: line, index: index)
        
        return line
    }
    
    private func normalize(ys: Vector, args: NormalizationArgs) -> Vector {
        let inset: CGFloat = verticalInset
        let maxY: CGFloat
        
        var side: CGFloat
        var bottomInset: CGFloat = 0.0
        var ys = ys
        
        let targetHeight = args.targetSize.height
        if isInFullSize {
            side = targetHeight
            maxY = args.maxPoint.y
        } else {
            ys = ys.map { $0 - args.minPoint.y }
            
            side = targetHeight - 2 * inset
            let minY = args.minPoint.y
            
            let delta = inset - minY
            if delta > 0 {
                side += delta
                bottomInset = minY
            } else {
                bottomInset = inset
            }
            maxY = args.maxPoint.y - args.minPoint.y
        }
        
        return normalize(vector: ys, side: side, max: maxY)
            .map { args.targetSize.height - ($0 + bottomInset) }
    }
    
    private func extend(line: Line) -> (line: Line, index: ExtendingIndex?) {
        guard let point = line.highlightedPoint,
            let index = line.points.firstIndex(where: { $0.x >= point.x }) else {
                return (line, nil)
        }
        
        guard line.points[index].x != point.x else {
            return (line, .existed(index))
        }
        
        var line = line
        line.points.insert(point, at: index)
        return (line, .new(index))
    }
    
    private func narrow(line: Line, index: ExtendingIndex?) -> Line {
        guard let index = index else {
            return line
        }
        
        var line = line
        
        let point: CGPoint
        switch index {
        case let .new(index):
            point = line.points.remove(at: index)
        case let .existed(index):
            point = line.points[index]
        }
        
        line.highlightedPoint = point
        
        return line
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

extension SizeNormalizer {
    
    enum ExtendingIndex {
        case new(Int)
        case existed(Int)
        
        var index: Int {
            switch self {
            case let .new(index), let .existed(index):
                return index
            }
        }
    }
}


