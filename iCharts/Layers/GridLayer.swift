//
//  GridLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class GridLayer: CALayer {
    
    var lineColor: UIColor = .gray {
        didSet {
            (sublayers as? [CAShapeLayer])?.forEach { $0.strokeColor = lineColor.cgColor }
        }
    }
    
    func render(props: Props) {
        backgroundColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)
        
        renderLines(props: props)
    }
    
    private func renderLines(props: Props) {
        sublayers = props.points.map { makePathLayer(point: $0, rectSize: props.rectSize) }
    }
    
    private func makePathLayer(point: CGPoint, rectSize: CGSize) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        layer.path = makePath(point: point, rectSize: rectSize)
        layer.strokeColor = lineColor.cgColor
        
        return layer
    }
    
    private func makePath(point: CGPoint, rectSize: CGSize) -> CGPath {
        let path = UIBezierPath()
        path.move(to: point)
        path.addLine(to: CGPoint(x: rectSize.width, y: point.y))
        return path.cgPath
    }
}

extension GridLayer {
    
    struct Props {
        let points: Points
        let rectSize: CGSize
    }
}
