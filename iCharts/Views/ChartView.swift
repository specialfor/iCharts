//
//  ChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit
import Utils

public final class ChartView: UIView {
    
    private var props: Props? {
        didSet { setNeedsLayout() }
    }
    
    private let gridLayer = GridLayer()
    private let lineChartLayer = LineChartLayer()
    

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    private func baseInit() {
        layer.addSublayer(gridLayer)
        layer.addSublayer(lineChartLayer)
    }
    
    
    // MARK: - UIView
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        guard let props = props else { return }
        
        renderGridLayer(props: props)
        renderLineChartLayer(props: props)
    }
    
    private func renderGridLayer(props: Props) {
        let lines = props.estimatedGridSpace.map { space in
            return GridLayer.Props.Lines(
                color: UIColor(hexString: "#efeff4").cgColor,
                count: Int(frame.size.height) / space)
        }
        
        let gridProps = GridLayer.Props(lines: lines, rectSize: frame.size)
        gridLayer.render(props: gridProps)
    }
    
    private func renderLineChartLayer(props: Props) {
        let lineChartProps = LineChartLayer.Props(
            lines: props.chart.lines,
            lineWidth: props.lineWidth,
            renderMode: .scaleToFill,
            rectSize: frame.size)
        
        lineChartLayer.render(props: lineChartProps)
    }
    
    
    // MARK: - render
    
    private var dispatchQueue = DispatchQueue.init(label: "cheburek", qos: .userInteractive)
    
    public func render(props: Props) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            
            let chart = self.adjustedChart(from: props)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.props = props
                self.props?.chart = chart
            }
        }
    }
    
    private func adjustedChart(from props: Props) -> LinearChart {
        var chart = props.chart
        
        guard let range = props.range, let (start, end) = points(chart: chart, range: range) else {
            return chart
        }
        
        chart.lines = chart.lines.map { transform(line: $0, start: start, end: end) }
        return chart
    }
    
    private func points(chart: LinearChart, range: Props.Range) -> (start: CGFloat, end: CGFloat)? {
        switch range {
        case let .percents(from, to):
            guard let minX = chart.lines.compactMap({ $0.points.xs.min() }).min(),
                let maxX = chart.lines.compactMap({ $0.points.xs.max() }).max() else {
                    return nil
            }
            
            let delta = maxX - minX
            
            return (delta * from + minX, delta * to + minX)
        case let .xs(from, to):
            return (from, to)
        }
    }
    
    private func transform(line: Line, start: CGFloat, end: CGFloat) -> Line {
        let points = line.points
        
        guard let from = points.firstIndex(where: { $0.x > start }),
            let to = points.lastIndex(where: { $0.x < end }) else {
                return line
        }
        
        var newPoints = Points()
        if from > 0 {
            newPoints.append(interpolate(from: points[from - 1], to: points[from], x: start))
        }
        
        newPoints.append(contentsOf: Array(points[from...to]))
        
        let lastIndex = points.count - 1
        if to < lastIndex - 1 {
            newPoints.append(interpolate(from: points[to], to: points[to + 1], x: end))
        }
        
        return Line(points: newPoints, color: line.color)
    }
    
    private func interpolate(from: CGPoint, to: CGPoint, x: CGFloat) -> CGPoint {
        let delta = to.x - from.x
        let factor = (x - from.x) / delta
        
        let y = from.y * (1 - factor) + to.y * factor
        
        return CGPoint(x: x, y: y)
    }
}

extension ChartView {
    
    public struct Props {
        public var chart: LinearChart
        public var lineWidth: CGFloat
        public var estimatedGridSpace: Int?
        public var range: Range?
        
        public init(chart: LinearChart, lineWidth: CGFloat = 1, estimatedGridSpace: Int? = nil, range: Range? = nil) {
            self.chart = chart
            self.lineWidth = lineWidth
            self.estimatedGridSpace = estimatedGridSpace
            self.range = range
        }
    }
}


extension ChartView.Props {
    
    public enum Range {
        case percents(from: CGFloat, to: CGFloat)
        case xs(from: CGFloat, to: CGFloat)
    }
}
