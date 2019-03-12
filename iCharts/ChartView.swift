//
//  ChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit

public final class ChartView: UIView {
    
    private let chartNormalizer = ChartNormalizer()
    
    private var props: Props? {
        didSet { setNeedsDisplay() }
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.sublayers?.forEach { $0.frame = layer.bounds }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        render()
    }
    
    public func render(props: Props) {
        self.props = props
    }
    
    private func render() {
        // need to animate from one path to another, if the first one exists
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        guard let props = props else {
            return
        }
        
        let chart = chartNormalizer.normalizer(chart: props.chart, size: bounds.size)
        
        makeLayers(for: chart).forEach {
            $0.frame = $0.bounds
            layer.addSublayer($0)
        }
    }
    
    private func makeLayers(for chart: Props.LinearChart) -> [CAShapeLayer] {
        return chart.lines.map { makeLayer(using: chart.xs, line: $0) }
    }
    
    private func makeLayer(using xs: Props.Vector, line: Props.LinearChart.Line) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = line.color.cgColor
        
        layer.path = makePath(using: xs, line: line).cgPath
        
        return layer
    }
    
    private func makePath(using xs: Props.Vector, line: Props.LinearChart.Line) -> UIBezierPath {
        let path = UIBezierPath()
        
        var points = zip(xs, line.ys).map { CGPoint(x: $0, y: $1) }
        
        let first = points.removeFirst()
        
        path.move(to: first)
        points.forEach { path.addLine(to: $0) }
        
        return path
    }
}

public extension ChartView {
    
    public struct Props {
        public typealias Vector = [CGFloat]
        
        public let chart: LinearChart
        
        public init(chart: LinearChart) {
            self.chart = chart
        }
    }
}

public extension ChartView.Props {
    
    public struct LinearChart {
        public var xs: Vector
        public var lines: [Line]
        
        public init(xs: Vector, lines: [Line]) {
            self.xs = xs
            self.lines = lines
        }
        
        public struct Line {
            let ys: Vector
            let color: UIColor
            
            public init(ys: Vector, color: UIColor) {
                self.ys = ys
                self.color = color
            }
        }
    }
}
