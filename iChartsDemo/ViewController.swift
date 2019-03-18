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
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        
        scrollView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.view)
        }
        
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor(hexString: "#6d6d72")
        label.text = "FOLLOWERS"
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview().inset(16)
        }
        
        return label
    }()

    lazy var chartView: DetailedChartView = {
        let view = DetailedChartView()
        
        view.backgroundColor = .white
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(label).offset(32)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return view
    }()
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "##efeff4")
        chartView.isHidden = false
        
        let props = makeProps()
        chartView.render(props: props)
    }
    
    private func makeProps() -> ChartView.Props {
        let lines = dataset.charts.map { chart in
            return Line(
                title: chart.name,
                xs: dataset.xs.dots,
                ys: chart.vector.dots,
                color: UIColor(hexString: chart.color))
        }
        return .init(chart: .init(lines: lines))
    }
}

