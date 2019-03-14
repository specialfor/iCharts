//
//  ChartScrollView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public final class ChartScrollView: View {
    
    override var activateViews: [UIView] {
        return [sliderView]
    }
    
    lazy var chartView: ChartView = {
        let view = ChartView()
        
        addSubview(view)
        
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var sliderView: ChartView = {
        let view = ChartView()
        
        view.backgroundColor = .white
        
        addSubview(view)

        view.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 8.0).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    // MARK: - View
    
    public func render(props: ChartView.Props) {
        chartView.render(props: props)
        sliderView.render(props: props)
    }
}
