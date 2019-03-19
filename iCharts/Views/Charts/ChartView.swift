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
    private let yLabelsLayer = YLabelsLayer()
    

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
        layer.addSublayer(yLabelsLayer)
    }
    
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let props = props else { return }
        
        renderGridLayer(props: props)
        renderLineChartLayer(props: props)
        renderYLabelsLayer(props: props)
    }
    
    private func renderGridLayer(props: Props) {
        let points = makePointsForHorizontalLines(props: props)
        let gridProps = GridLayer.Props(
            points: points,
            lineColor: UIColor(hexString: "#efeff4").cgColor,
            rectSize: frame.size)
        gridLayer.render(props: gridProps)
    }
    
    private func makePointsForHorizontalLines(props: Props) -> Points {
        guard let space = props.estimatedGridSpace else {
            return Points()
        }
        
        let count = Int(frame.size.height) / space
        
        return (1...count).map { index in
            CGPoint(x: 0, y: index * space)
        }
    }
    
    private func renderLineChartLayer(props: Props) {
        let lineChartProps = LineChartLayer.Props(
            lines: props.lines,
            lineWidth: props.lineWidth,
            renderMode: .scaleToFill,
            rectSize: frame.size)
        
        lineChartLayer.render(props: lineChartProps)
    }
    
    private func renderYLabelsLayer(props: Props) {
        let labels = makeLabels(props: props)
        let yLabelsProps = YLabelsLayer.Props(
            labels: labels,
            textColor: UIColor(hexString: "#989ea3").cgColor,
            rectSize: frame.size)
        yLabelsLayer.render(props: yLabelsProps)
    }
    
    private func makeLabels(props: Props) -> [YLabelsLayer.Props.Label] {
        guard let maxY = props.lines.compactMap({ $0.points.ys.max() }).max(), let space = props.estimatedGridSpace else {
            return []
        }
        
        let count = Int(frame.size.height) / space
        let step = Int(maxY) / count
        
        let points = makePointsForHorizontalLines(props: props)
        let values = (0..<count).map { index in
            return "\(index * step)"
        }.reversed()
        
        return zip(points, values) { point, value in
            return YLabelsLayer.Props.Label(point: point, value: value)
        }
    }
    
    
    // MARK: - render
    
    private var dispatchQueue = DispatchQueue.init(label: "cheburek", qos: .userInteractive)
    
    public func render(props: Props) {
        renderSync(props: props)
    }
    
    private func renderSync(props: Props) {
        var props = props
        props.lines = adjustedLines(from: props)
        self.props = props
    }
    
    private func renderAsync(props: Props) {
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            
            let lines = self.adjustedLines(from: props)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                var props = props
                props.lines = lines
                self.props = props
            }
        }
    }
    
    private func adjustedLines(from props: Props) -> [Line] {
        let lines = props.lines
        guard let range = props.range, let (start, end) = points(lines: lines, range: range) else {
            return lines
        }
        
        return lines.map { transform(line: $0, start: start, end: end) }
    }
    
    private func points(lines: [Line], range: Props.Range) -> (start: CGFloat, end: CGFloat)? {
        switch range {
        case let .percents(from, to):
            guard let minX = lines.compactMap({ $0.points.xs.min() }).min(),
                let maxX = lines.compactMap({ $0.points.xs.max() }).max() else {
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
        
        var line = line
        line.points = newPoints
        return line
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
        public var lines: [Line]
        public var lineWidth: CGFloat
        public var estimatedGridSpace: Int?
        public var range: Range?
        
        public init(lines: [Line], lineWidth: CGFloat = 1, estimatedGridSpace: Int? = nil, range: Range? = nil) {
            self.lines = lines
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
