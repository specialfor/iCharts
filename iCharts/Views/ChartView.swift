//
//  ChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit

public final class ChartView: UIView {
    
    private var props: Props?
    private var adjustedChart: LinearChart? {
        didSet { setNeedsLayout() }
    }
    
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
        layer.addSublayer(lineChartLayer)
    }
    
    
    // MARK: - UIView
    
    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if let chart = adjustedChart {
            let lineChartProps = LineChartLayer.Props(
                lines: chart.lines,
                renderMode: .scaleToFill,
                rectSize: layer.frame.size)
            
            lineChartLayer.render(props: lineChartProps)
        }
    }
    
    
    // MARK: - render
    
    private var dispatchQueue = DispatchQueue.init(label: "cheburek", qos: .userInteractive)
    
    public func render(props: Props) {
        self.props = props
        
//        dispatchQueue.async { [weak self] in
//            guard let self = self else { return }
            let chart = self.adjustedChart(from: props)
            
//            DispatchQueue.main.async {
                self.adjustedChart = chart
//            }
//        }
    }
    
    private func adjustedChart(from props: Props) -> LinearChart {
        var chart = props.chart
        
        guard let range = props.range, let (start, end) = points(chart: chart, range: range) else {
            return chart
        }
        
        chart.lines = chart.lines.map { line in
            let points = line.points.reduce(into: Points()) { result, point in
                if (start...end).contains(point.x) {
                    result.append(point)
                }
            }
            
            return Line(points: points, color: line.color)
        }

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
}

extension ChartView {
    
    public struct Props {
        public var chart: LinearChart
        public var range: Range?
        
        public init(chart: LinearChart, range: Range? = nil) {
            self.chart = chart
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
