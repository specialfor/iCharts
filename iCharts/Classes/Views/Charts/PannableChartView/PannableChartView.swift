//
//  PannableChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
}()

private let yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
}()

public final class PannableChartView: UIControl {
    
    private var highlightedX: CGFloat? {
        didSet { props?.highlithedX = highlightedX }
    }
    
    private var props: ChartView.Props? {
        didSet { setNeedsLayout() }
    }
    
    private var leadingConstraint: NSLayoutConstraint!
    
    private var workItem: DispatchWorkItem?
    
    public var colors: Colors = .initial {
        didSet { setupColors() }
    }
    
    private func setupColors() {
        chartView.colors = colors.chart
        infoView.colors = colors.chartInfo
    }
    
    // MARK: - Subviews
    
    lazy var chartView: ChartView = {
        let view = ChartView()
        
        addSubview(view) { superview in
            return view.edgesConstraints(to: superview)
        }
        
        return view
    }()
    
    lazy var infoView: ChartInfoView = {
        let view = ChartInfoView()
        
        addSubview(view) { _ in
            leadingConstraint = view.leadingAnchor.constraint(equalTo: chartView.leadingAnchor)
            
            return [
                view.topAnchor.constraint(equalTo: chartView.topAnchor, constant: 8.0),
                leadingConstraint
            ]
        }
        
        return view
    }()
    
    
    // MARK: - UIControl
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseSetup()
    }
    
    func baseSetup() {
        [chartView, infoView].forEach { $0.isUserInteractionEnabled = false }
        infoView.alpha = 0
        setupColors()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }

    private func render() {
        guard let props = props else { return }
        chartView.render(props: props)
        
        if props.lines.isEmpty {
            hide()
        } else if props.highlithedX != nil {
            endTracking()
        }
    }
    
    // MARK: - Render
    
    func render(props: ChartView.Props) {
        var props = props
        props.highlithedX = highlightedX
        props.didHighlightX = { [weak self] output in
            guard let self = self else { return }
            self.renderChartInfoView(output: output)
        }
        self.props = props
    }
    
    private func renderChartInfoView(output: ChartView.Output) {
        let date = Date(timeIntervalSince1970: TimeInterval(output.xValue / 1000))
        let lineValues = output.yValues.map { ChartInfoView.Props.LineValue(value: "\(Int($0.value))", color: $0.color) }
        
        let infoProps = ChartInfoView.Props(
            dateMonth: dateFormatter.string(from: date),
            year: yearFormatter.string(from: date),
            lineValues: lineValues)
        infoView.render(props: infoProps)
    }
    
    
    // MARK: - Handle tracking
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        highlight(using: touch)
        UIView.animate(withDuration: 0.3) {
            self.infoView.alpha = 1.0
        }
        return true
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        highlight(using: touch)
        return true
    }
    
    private func highlight(using touch: UITouch) {
        let point = touch.location(in: self)
        highlightedX = point.x
        leadingConstraint.constant = leadingInset(point: point)
    }
    
    private func leadingInset(point: CGPoint) -> CGFloat {
        let width = infoView.frame.width
        return min(max(0, point.x - width / 2), frame.width - width)
    }
    
    private func endTracking() {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem!)
    }
    
    private func hide() {
        self.highlightedX = nil
        UIView.animate(withDuration: 0.3, animations: {
            self.infoView.alpha = 0.0
        })
    }
}


extension PannableChartView {
    
    public struct Colors {
        public let chart: ChartView.Colors
        public let chartInfo: ChartInfoView.Colors

        public init(chart: ChartView.Colors, chartInfo: ChartInfoView.Colors) {
            self.chart = chart
            self.chartInfo = chartInfo
        }
        
        public static let initial = Colors(chart: .initial, chartInfo: .initial)
    }
}
