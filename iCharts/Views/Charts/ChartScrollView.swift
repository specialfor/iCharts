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
    
    
    // MARK: - Subviews
    
    lazy var chartView: ChartView = {
        let view = ChartView()
        
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
        props.highlithedX = 40
        props.estimatedGridSpace = 50
        
        let sliderState = sliderView.sliderState
        props.range = .percents(from: sliderState.startBound, to: sliderState.endBound)
        
        return props
    }
}
