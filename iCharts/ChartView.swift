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
        didSet { render() }
    }
    
    private var shapeLayers: [CAShapeLayer]? {
        get { return layer.sublayers as? [CAShapeLayer] }
        set { layer.sublayers = newValue }
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        shapeLayers?.forEach { $0.frame = layer.bounds }
        render()
    }
    
    public func render(props: Props) {
        adjustNumberOfLayers(props: props)
        self.props = props
    }
    
    private func adjustNumberOfLayers(props: Props) {
        let layersCount = shapeLayers?.count ?? 0
        let linesCount = props.chart.lines.count
        
        if layersCount < linesCount {
            (0..<linesCount - layersCount).forEach { _ in
                let shapeLayer = CAShapeLayer()
                shapeLayer.fillColor = UIColor.clear.cgColor
                layer.addSublayer(shapeLayer)
            }
        } else if layersCount > linesCount, let sublayers = shapeLayers {
            shapeLayers = Array(sublayers.dropLast(layersCount - linesCount))
        }
    }
    
    private func render() {
        guard let props = props, let layers = shapeLayers else {
            return
        }
        
        let chart = chartNormalizer.normalize(chart: props.chart, size: bounds.size)
        
        chart.lines.enumerated().forEach { index, line in
            let layer = layers[index]
            layer.path = layer.presentation()?.path
            layer.strokeColor = layer.presentation()?.strokeColor
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        
        chart.lines.enumerated().forEach { index, line in
            let layer = layers[index]
            let animation = makeAnimation(for: layer, chart: chart, line: line)
            layer.add(animation, forKey: "\(index).layer animation")
        }
        
        CATransaction.commit()
    }
    
    private func makeAnimation(for layer: CAShapeLayer,
                               chart: Props.LinearChart,
                               line: Props.LinearChart.Line) -> CAAnimation {
        let group = CAAnimationGroup()
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = layer.path
        let path = makePath(using: chart.xs, line: line).cgPath
        pathAnimation.toValue = path
        layer.path = path
        
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = layer.strokeColor
        let strokeColor = line.color.cgColor
        strokeColorAnimation.toValue = strokeColor
        layer.strokeColor = strokeColor
        
        group.animations = [pathAnimation, strokeColorAnimation]
        
        return group
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
