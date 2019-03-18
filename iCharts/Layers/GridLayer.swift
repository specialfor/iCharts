//
//  GridLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class GridLayer: CAShapeLayer {
    
    func render(props: Props) {
        fillColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)

        renderLines(lines: props.lines)
    }
    
    private func renderLines(lines: Props.Lines?) {
        guard let lines = lines else { return }
        
        path = makePath(using: lines).cgPath
        strokeColor = lines.color
    }
    
    private func makePath(using lines: Props.Lines) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        let count = lines.count
        let space = frame.height / CGFloat(count)
        
        (1...count).forEach { index in
            let y = CGFloat(index) * space
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.maxX, y: y))
        }
        
        return path
    }}

extension GridLayer {
    
    struct Props {
        let lines: Lines?
        let rectSize: CGSize
        
        struct Lines {
            let color: CGColor
            let count: Int
        }
    }
}
