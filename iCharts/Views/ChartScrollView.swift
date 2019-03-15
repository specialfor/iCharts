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
        
        view.backgroundColor = .white
        
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
    
    
    // MARK: - View
    
    public func render(props: ChartView.Props) {
        chartView.render(props: props)
        sliderChartView.render(props: props)
    }
}
