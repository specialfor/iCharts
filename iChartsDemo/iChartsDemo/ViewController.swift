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

class ViewController: UIViewController {
    
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
    
    lazy var chartView: ChartView = {
        let view = ChartView()
        
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(label).offset(32)
            make.left.right.equalTo(label)
            make.height.equalTo(320)
        }
        
        return view
    }()
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        label.text = "Cheburek"
        
        chartView.render(props: makeProps())
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        chartView.addGestureRecognizer(recognizer)
        chartView.isUserInteractionEnabled = true
    }
    
    var counter = 0
    
    @objc private func tap() {
        counter = (counter + 1) % 2
        
        if counter == 0 {
            chartView.render(props: makeProps())
        } else {
            chartView.render(props: makeProps2())
        }
    }
    
    private func makeProps() -> ChartView.Props {
        return .init(chart: .init(
            xs: [1, 10, 50, 200],
            lines: [
                .init(
                    ys: [10, 30, 20, 60],
                    color: .red)
            ]))
    }
    
    private func makeProps2() -> ChartView.Props {
        return .init(chart: .init(
            xs: [1, 10, 50, 70, 80, 110, 120, 200],
            lines: [
                .init(
                    ys: [10, 50, 90, 80, 70, 60, 50, 30],
                    color: .blue),
                .init(
                    ys: [1, 10, 50, 70, 80, 110, 120, 200],
                    color: .green
                )
            ]))
    }
    
    private func parseDatasets() -> [Dataset] {
        guard let filePath = Bundle.main.path(forResource: "chart_data", ofType: "json") else {
            return []
        }
        
        do {
            let datasets = try DatasetJSONParser().parse(from: filePath)
            return datasets
        } catch {
            print(error)
            return []
        }
    }
}

