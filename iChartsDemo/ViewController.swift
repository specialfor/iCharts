//
//  ViewController.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit
import SnapKit
import iCharts

final class ViewController: UIViewController, UIScrollViewDelegate {
    
    let dataset: Dataset
    
    init(dataset: Dataset) {
        self.dataset = dataset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Subviews
    
    lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.left.right.equalToSuperview().inset(16)
        }
        
        return label
    }()
    
    lazy var chartView: ChartScrollView = {
        let view = ChartScrollView()
        
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(label).offset(32)
            make.left.right.equalTo(label)
            make.height.equalTo(400)
        }
        
        return view
    }()
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        label.text = "Cheburek"
        
        let props = makeProps()
        chartView.render(props: props)
    }
    
    private func makeProps() -> ChartView.Props {
        let lines = dataset.charts.map { chart in
            return Line(
                xs: dataset.xs.dots,
                ys: chart.vector.dots,
                color: UIColor(hexString: chart.color))
        }
        return .init(chart: .init(lines: lines))
    }
}

