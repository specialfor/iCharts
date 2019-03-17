//
//  Normalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/12/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Utils

private var dispatchQueue = DispatchQueue(label: "normalizer-queue", qos: .userInteractive)

struct NormalizationArgs {
    let minPoint: CGPoint
    let maxPoint: CGPoint
    let targetSize: CGSize
}

protocol Normalizer {
    func unsafeNormalize(line: Line, args: NormalizationArgs) -> Line
}

extension Normalizer {
    
    func normalize(chart: LinearChart, rectSize: CGSize) -> LinearChart {
        var chart = chart
        
        guard let args = makeNormalizationArgs(for: chart, rectSize: rectSize) else {
            return chart
        }
        
        chart.lines = chart.lines.map { normalize(line: $0, args: args) }
        return chart
    }
    
    func normalize(chart: LinearChart, rectSize: CGSize, completion: @escaping (Result<LinearChart>) -> Void) {
        
        dispatchQueue.async {
            guard let args = self.makeNormalizationArgs(for: chart, rectSize: rectSize) else {
                DispatchQueue.main.async {
                    completion(.failure(nil))
                }
                return
            }
            
            let newLines = chart.lines.map { self.normalize(line: $0, args: args) }
            
            let chart = LinearChart(lines: newLines)
            
            DispatchQueue.main.async {
                completion(.success(chart))
            }
        }
    }
    
    private func makeNormalizationArgs(for chart: LinearChart, rectSize: CGSize) -> NormalizationArgs? {
        guard let minX = chart.lines.compactMap({ $0.points.first?.x }).min(),
            let maxX = chart.lines.compactMap({ $0.points.last?.x }).max(),
            let minY = chart.lines.compactMap({ $0.points.ys.min() }).min(),
            let maxY = chart.lines.compactMap({ $0.points.ys.max() }).max() else {
                return nil
        }
        
        return NormalizationArgs(
            minPoint: CGPoint(x: minX, y: minY),
            maxPoint: CGPoint(x: maxX, y: maxY),
            targetSize: rectSize)
    }
    
    func normalize(line: Line, args: NormalizationArgs) -> Line {
        guard !line.points.isEmpty else {
            return line
        }
        
        return unsafeNormalize(line: line, args: args)
    }
    
    /// Xmin = X0, X ~> X' = { x' in [0, C] }
    func normalize(xs: Vector, min: CGFloat) -> Vector {
        return xs.map { $0 - min }
    }
}

