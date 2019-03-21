//
//  ChartScrollView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public final class ChartScrollView: View {
    
    override var activateViews: [UIView] {
        return [sliderChartView]
    }
    
    private var props: ChartView.Props? {
        didSet { setNeedsLayout() }
    }
    
    public var colors: Colors = .initial {
        didSet { setupColors() }
    }
    
    private func setupColors() {
        chartView.colors = colors.chart
        sliderView.colors = colors.slider
    }
    
    
    // MARK: - Subviews
    
    lazy var chartView: PannableChartView = {
        let view = PannableChartView()
        
        addSubview(view)
        view.makeCosntraints {
            return [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.leftAnchor.constraint(equalTo: leftAnchor),
                view.rightAnchor.constraint(equalTo: rightAnchor)
            ]
        }
        
        return view
    }()
    
    lazy var sliderView: ExpandableSliderView = {
        let view = ExpandableSliderView()
        
        view.addTarget(self, action: #selector(valueChanged(in:)), for: .valueChanged)
        
        addSubview(view)
        view.makeCosntraints {
            return [
                view.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 8.0),
                view.leftAnchor.constraint(equalTo: leftAnchor),
                view.rightAnchor.constraint(equalTo: rightAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.heightAnchor.constraint(equalToConstant: 44.0)
            ]
        }
        
        return view
    }()
    
    lazy var sliderChartView: ChartView = {
        let view = ChartView()
        
        view.backgroundColor = .clear
        
        let superView = sliderView.contentView
        
        superView.addSubview(view)
        view.makeCosntraints {
            return [
                view.topAnchor.constraint(equalTo: superView.topAnchor),
                view.leftAnchor.constraint(equalTo: superView.leftAnchor),
                view.rightAnchor.constraint(equalTo: superView.rightAnchor),
                view.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
            ]
        }
        
        return view
    }()
    
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    
    override func baseSetup() {
        super.baseSetup()
        setupColors()
    }
    
    // MARK: - Render
    
    public func render(props: ChartView.Props) {
        self.props = props
    }
    
    
    // MARK: - Actions
    
    @objc private func valueChanged(in sliderView: ExpandableSliderView) {
        render()
    }
    
    private func render() {
        guard let props = self.props else {
            return
        }
        
        let rangedProps = makeRangedProps(props: props)
        chartView.render(props: rangedProps)
        
        var sliderChartProps = props
        sliderChartProps.estimatedXLabelWidth = nil
        sliderChartView.render(props: sliderChartProps)
    }
    
    private func makeRangedProps(props: ChartView.Props) -> ChartView.Props {
        var props = props
        props.lineWidth = 2
        props.estimatedGridSpace = 50
        
        let sliderState = sliderView.sliderState
        props.range = .percents(from: sliderState.startBound, to: sliderState.endBound)
        
        return props
    }
}


extension ChartScrollView {
    
    public struct Colors {
        public let chart: PannableChartView.Colors
        public let slider: ExpandableSliderView.Colors

        public init(chart: PannableChartView.Colors, slider: ExpandableSliderView.Colors) {
            self.chart = chart
            self.slider = slider
        }
        
        public static let initial = Colors(chart: .initial, slider: .initial)
    }
}
