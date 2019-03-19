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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let props = props else { return }
        
        renderGridLayer(props: props)
        renderLineChartLayer(props: props)
    }
    
    private func renderGridLayer(props: Props) {
        let maxY = props.lines.compactMap { $0.points.ys.max() }.max()
        let lines = props.estimatedGridSpace.map { space in
            return GridLayer.Props.Lines(
                yLabels: makeYValues(maxY: maxY, space: space),
                lineColor: UIColor(hexString: "#efeff4").cgColor,
                textColor: UIColor(hexString: "#989ea3").cgColor)
        }
        
        let gridProps = GridLayer.Props(lines: lines, rectSize: frame.size)
        gridLayer.render(props: gridProps)
    }
    
    private func makeYValues(maxY: CGFloat?, space: Int) -> [String] {
        guard let maxY = maxY else { return [] }
        
        let count = Int(frame.size.height) / space
        let step = Int(maxY) / count
        
        return (0..<count).map { index in
            return "\(index * step)"
        }.reversed()
    }
    
    private func renderLineChartLayer(props: Props) {
        let lineChartProps = LineChartLayer.Props(
            lines: props.lines,
            lineWidth: props.lineWidth,
            renderMode: .scaleToFill,
            rectSize: frame.size)
        
        lineChartLayer.render(props: lineChartProps)
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
