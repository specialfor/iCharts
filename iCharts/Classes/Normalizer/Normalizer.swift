//
//  Normalizer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/12/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

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
    
    func normalize(lines: [Line], rectSize: CGSize) -> [Line] {
        guard let args = makeNormalizationArgs(using: lines, rectSize: rectSize) else {
            return lines
        }
        
        return lines.map { normalize(line: $0, args: args) }
    }
    
    func normalize(lines: [Line], rectSize: CGSize, completion: @escaping (Result<[Line]>) -> Void) {
        
        dispatchQueue.async {
            guard let args = self.makeNormalizationArgs(using: lines, rectSize: rectSize) else {
                DispatchQueue.main.async {
                    completion(.failure(nil))
                }
                return
            }
            
            let newLines = lines.map { self.normalize(line: $0, args: args) }
            
            DispatchQueue.main.async {
                completion(.success(newLines))
            }
        }
    }
    
    private func makeNormalizationArgs(using lines: [Line], rectSize: CGSize) -> NormalizationArgs? {
        guard let minX = lines.compactMap({ $0.points.first?.x }).min(),
            let maxX = lines.compactMap({ $0.points.last?.x }).max(),
            let minY = lines.compactMap({ $0.points.ys.min() }).min(),
            let maxY = lines.compactMap({ $0.points.ys.max() }).max() else {
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

