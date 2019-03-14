//
//  ChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit

public final class ChartView: UIView {
    
    private var props: Props? {
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
        
        if let props = props {
            let lineChartProps = LineChartLayer.Props(
                lines: props.chart.lines,
                renderMode: .scaleToFill,
                rectSize: layer.frame.size)
            
            lineChartLayer.render(props: lineChartProps)
        }
    }
    
    
    // MARK: - render
    
    public func render(props: Props) {
        self.props = props
    }
}

public extension ChartView {
    
    public struct Props {
        public var chart: LinearChart
        
        public init(chart: LinearChart) {
            self.chart = chart
        }
    }
}
