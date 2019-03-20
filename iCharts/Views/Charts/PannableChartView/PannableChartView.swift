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

final class PannableChartView: UIControl {
    
    private var props: ChartView.Props? {
        didSet { setNeedsLayout() }
    }
    
    private var leadingConstraint: NSLayoutConstraint!
    
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseSetup()
    }
    
    func baseSetup() {
        [chartView, infoView].forEach { $0.isUserInteractionEnabled = false }
        infoView.alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }

    private func render() {
        guard let props = props else { return }
        chartView.render(props: props)
    }
    
    // MARK: - Render
    
    func render(props: ChartView.Props) {
        var props = props
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
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        highlight(using: touch)
        UIView.animate(withDuration: 0.3) {
            self.infoView.alpha = 1.0
        }
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        highlight(using: touch)
        return true
    }
    
    private func highlight(using touch: UITouch) {
        let point = touch.location(in: self)
        props?.highlithedX = point.x
        leadingConstraint.constant = leadingInset(point: point)
    }
    
    private func leadingInset(point: CGPoint) -> CGFloat {
        let width = infoView.frame.width
        return min(max(0, point.x - width / 2), frame.width - width)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        endTracking()
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        endTracking()
    }
    
    private func endTracking() {
        UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
            self.infoView.alpha = 0.0
        }) { isFinished in
            if isFinished {
                self.props?.highlithedX = nil
            }
        }
    }
}
