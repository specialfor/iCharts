//
//  ChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit
import Utils

private let xLabelsHeight: CGFloat = 30.0

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
}()

public final class ChartView: UIView {

    private var props: Props? {
        return extendedProps?.props
    }
    
    private var extendedProps: ExtendedProps? {
        didSet { setNeedsLayout() }
    }
    
    private let gridLayer = GridLayer()
    private let lineChartLayer = LineChartLayer()
    private let yLabelsLayer = YLabelsLayer()
    private let xLabelsLayer = XLabelsLayer()
    
    private var sizeWithoutXLabels: CGSize {
        var size = frame.size
        
        guard props?.estimatedXLabelWidth != nil else {
            return size
        }
        
        size.height -= xLabelsHeight
        return size
    }
    
    private var xLabelsRect: CGRect {
        guard props?.estimatedXLabelWidth != nil else {
            return .zero
        }
        
        return CGRect(
            x: 0,
            y: sizeWithoutXLabels.height,
            width: frame.size.width,
            height: xLabelsHeight)
    }
    
    public var colors: Colors = .initial {
        didSet { setupColors() }
    }
    
    private func setupColors() {
        CATransaction.performWithoutAnimation { _ in
            gridLayer.lineColor = colors.horizontalLines
            lineChartLayer.colors = colors.lineChart
            yLabelsLayer.textColor = colors.labels
            xLabelsLayer.textColor = colors.labels
        }
    }
    
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
        layer.addSublayer(xLabelsLayer)
    }
    
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        renderLayers()
        setupColors()
    }
    
    private func renderLayers() {
        guard let extendedProps = extendedProps else { return }
        let props = extendedProps.props
        
        renderGridLayer(props: props)
        renderLineChartLayer(props: props)
        renderYLabelsLayer(props: extendedProps)
        renderXLabelsLayer(props: extendedProps)
    }
    
    private func renderGridLayer(props: Props) {
        let points = makePointsForHorizontalLines(props: props)
        let gridProps = GridLayer.Props(
            points: points,
            rectSize: sizeWithoutXLabels)
        gridLayer.render(props: gridProps)
    }
    
    private func makePointsForHorizontalLines(props: Props) -> Points {
        guard let space = props.estimatedGridSpace else {
            return Points()
        }
        
        let count = Int(sizeWithoutXLabels.height) / space
        let adjustedSpace = sizeWithoutXLabels.height / CGFloat(count)
        
        return (1...count).map { index in
            CGPoint(x: 0, y: CGFloat(index) * adjustedSpace)
        }
    }
    
    private func renderLineChartLayer(props: Props) {
        let lineChartProps = LineChartLayer.Props(
            lines: props.lines,
            lineWidth: props.lineWidth,
            highlightedX: props.highlithedX,
            isInFullSize: props.isInFullSize,
            rectSize: sizeWithoutXLabels)
        
        lineChartLayer.render(props: lineChartProps)
    }
    
    private func renderYLabelsLayer(props: ExtendedProps) {
        let labels = makeYLabels(props: props)
        let yLabelsProps = YLabelsLayer.Props(
            labels: labels,
            rectSize: sizeWithoutXLabels)
        yLabelsLayer.render(props: yLabelsProps)
    }
    
    private func makeYLabels(props extendedProps: ExtendedProps) -> [YLabelsLayer.Props.Label] {
        let props = extendedProps.props
        
        guard let limits = extendedProps.limits,
            let space = props.estimatedGridSpace else {
                return []
        }
        
        let maxY = limits.to.y
        let minY = limits.from.y
        
        let count = Int(sizeWithoutXLabels.height) / space
        let step = (maxY - minY) / CGFloat(count)
        
        let points = makePointsForHorizontalLines(props: props)
        
        let values: [String] = (0..<count)
            .map { index in
                let value = CGFloat(index) * step + minY
                return "\(Int(value))"
            }.reversed()
        
        return zip(points, values) { point, value in
            return YLabelsLayer.Props.Label(point: point, value: value)
        }
    }
    
    private func renderXLabelsLayer(props: ExtendedProps) {
        let (labels, width) = makeXLabels(props: props)
        let xLabelsProps = XLabelsLayer.Props(
            labels: labels,
            labelWidth: width,
            rect: xLabelsRect)
        xLabelsLayer.render(props: xLabelsProps)
    }
    
    private func makeXLabels(props: ExtendedProps) -> (labels: [XLabelsLayer.Props.Label], width: CGFloat) {
        guard let width = props.props.estimatedXLabelWidth,
            let limits = props.limits else {
                return (labels: [], width: 0)
        }
        
        let space: CGFloat = 8.0
        let expandedLayerWidth = xLabelsRect.size.width + space
        let expandedWidth = width + Int(space)
        let count = Int(expandedLayerWidth) / (expandedWidth)
        
        let adjustedWidth = expandedLayerWidth / CGFloat(count)
        
        return (
            labels: (0..<count).map { index in
                let x = CGFloat(index) * adjustedWidth
                
                let labelX: CGFloat
                switch index {
                case 0:
                    labelX = 0
                case 1..<(count - 1):
                    labelX = x + adjustedWidth / 2
                default:
                    labelX = frame.size.width
                }
                
                let label = xLabel(at: labelX, limits: limits)
                
                return XLabelsLayer.Props.Label(
                    point: CGPoint(x: x, y: 0),
                    value: label)
            },
            width: adjustedWidth - space
        )
    }
    
    private func xLabel(at x: CGFloat, limits: Limits) -> String {
        let factor = x / xLabelsRect.size.width
        let timestamp = limits.from.x + (limits.to.x - limits.from.x) * factor
        
        let seconds = timestamp / 1000.0
        let date = Date(timeIntervalSince1970: TimeInterval(seconds))
        
        return dateFormatter.string(from: date)
    }
    
    
    // MARK: - Render
    
    private var dispatchQueue = DispatchQueue.init(label: "cheburek", qos: .userInteractive)
    
    public func render(props: Props) {
        var props = props
        let (lines, limits) = adjustedLines(from: props)
        props.lines = lines
        extendedProps = ExtendedProps(props: props, limits: limits)
        makeOutput(props: props).try { props.didHighlightX?($0) }
    }
    
    private func makeOutput(props: Props) -> Output? {
        guard let xValue = props.lines.first?.highlightedPoint?.x else {
                return nil
        }
        
        let yValues = props.lines.map { line -> Output.YValue? in
            guard let point = line.highlightedPoint else {
                return nil
            }
            
            return Output.YValue(value: point.y, color: line.color)
            }.compactMap { $0 }
        
        guard !yValues.isEmpty else {
            return nil
        }
        
        return Output(xValue: xValue, yValues: yValues)
    }
    
    private func adjustedLines(from props: Props) -> (lines: [Line], limits: Limits?) {
        var lines = props.lines
        var segment = props.range.flatMap { self.segment(lines: lines, range: $0) }
        
        if let segment = segment {
            lines = lines.map { transform(line: $0, segment: segment, highlightedX: props.highlithedX) }
        } else {
            segment = self.segment(lines: lines, range: .percents(from: 0, to: 1))
        }
        
        return (lines, makeLimits(lines: lines, segment: segment))
    }
    
    private func makeLimits(lines: [Line], segment: Segment<CGFloat>?) -> Limits? {
        guard let segment = segment,
            let minY = lines.compactMap({ $0.points.ys.min() }).min(),
            let maxY = lines.compactMap({ $0.points.ys.max() }).max() else {
                return nil
        }
        
        return Limits(
            from: CGPoint(x: segment.from, y: minY),
            to: CGPoint(x: segment.to, y: maxY))
    }
    
    private func segment(lines: [Line], range: Props.Range) -> Segment<CGFloat>? {
        switch range {
        case let .percents(from, to):
            guard let minX = lines.compactMap({ $0.points.xs.min() }).min(),
                let maxX = lines.compactMap({ $0.points.xs.max() }).max() else {
                    return nil
            }
            
            let delta = maxX - minX
            return Segment(from: delta * from + minX, to: delta * to + minX)
        case let .xs(from, to):
            return Segment(from: from, to: to)
        }
    }
    
    private func transform(line: Line, segment: Segment<CGFloat>, highlightedX: CGFloat?) -> Line {
        var line = slice(line: line, segment: segment)
        line.highlightedPoint = highlightedX.flatMap { highlightedPoint(at: $0, line: line) }
        return line
    }
    
    private func slice(line: Line, segment: Segment<CGFloat>) -> Line {
        let points = line.points
        let start = segment.from
        let end = segment.to
        
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
    
    private func highlightedPoint(at x: CGFloat, line: Line) -> CGPoint? {
        let factor = x / frame.width
        
        
        // MARK: - replace with segmant
        guard let min = line.points.xs.min(),
            let max = line.points.xs.max() else {
                return nil
        }
        
        let lineX = min + (max - min) * factor
        
        // FIXME: it would not work if charts have different xs
        guard let from = line.points.last(where: { $0.x < lineX }) else {
            return line.points.first
        }
        
        guard let to = line.points.first(where: { $0.x > lineX }) else {
            return line.points.last
        }
        
        return interpolate(from: from, to: to, x: lineX)
    }
    
    private func interpolate(from: CGPoint, to: CGPoint, x: CGFloat) -> CGPoint {
        let delta = to.x - from.x
        let factor = (x - from.x) / delta
        
        let y = from.y * (1 - factor) + to.y * factor
        
        return CGPoint(x: x, y: y)
    }
}

extension ChartView {
    
    public struct Colors {
        public let labels: UIColor
        public let horizontalLines: UIColor
        public let lineChart: LineChartLayer.Colors
        
        public init(labels: UIColor, horizontalLines: UIColor, lineChart: LineChartLayer.Colors) {
            self.labels = labels
            self.horizontalLines = horizontalLines
            self.lineChart = lineChart
        }
        
        public static let initial = Colors(
            labels: .gray,
            horizontalLines: .gray,
            lineChart: .initial)
    }
    
    public struct Props {
        public var lines: [Line]
        public var lineWidth: CGFloat
        public var highlithedX: CGFloat?
        public var estimatedGridSpace: Int?
        public var estimatedXLabelWidth: Int?
        public var isInFullSize: Bool
        public var range: Range?
        public var didHighlightX: ClosureWith<Output>?
        
        public init(lines: [Line],
                    lineWidth: CGFloat = 1,
                    highlithedX: CGFloat? = nil,
                    estimatedGridSpace: Int? = nil,
                    estimatedXLabelWidth: Int? = 40,
                    isInFullSize: Bool = true,
                    range: Range? = nil,
                    didHighlightX: ClosureWith<Output>? = nil) {
            self.lines = lines
            self.lineWidth = lineWidth
            self.highlithedX = highlithedX
            self.estimatedGridSpace = estimatedGridSpace
            self.estimatedXLabelWidth = estimatedXLabelWidth
            self.isInFullSize = isInFullSize
            self.range = range
            self.didHighlightX = didHighlightX
        }
    }
    
    public struct Output {
        public let xValue: CGFloat
        public let yValues: [YValue]
    
        public init(xValue: CGFloat, yValues: [YValue]) {
            self.xValue = xValue
            self.yValues = yValues
        }
        
        public struct YValue {
            public let value: CGFloat
            public let color: UIColor
            
            public init(value: CGFloat, color: UIColor) {
                self.value = value
                self.color = color
            }
        }
    }
}


extension ChartView.Props {
    
    public enum Range {
        case percents(from: CGFloat, to: CGFloat)
        case xs(from: CGFloat, to: CGFloat)
    }
}

private extension ChartView {
    typealias Limits = Segment<CGPoint>
    
    struct ExtendedProps {
        
        var props: Props
        var limits: Limits?
    }
}
