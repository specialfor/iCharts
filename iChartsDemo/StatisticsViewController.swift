//
//  StatisticsViewController.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import UIKit
import SnapKit
import iCharts
import Utils

private let cellIdentifier = "lol-kek-cheburek"

final class StatisticsViewController: UIViewController {
    
    let datasets: [Dataset]
    let themeManager: ThemeManager
    
    var colors: ThemeColors {
        return themeManager.currentTheme.colors
    }
    
    init(datasets: [Dataset], themeManager: ThemeManager = ThemeManager()) {
        self.datasets = datasets
        self.themeManager = themeManager
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
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "FOLLOWERS"
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.left.right.equalToSuperview().inset(16)
        }
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 16.0
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
        }
        
        return stackView
    }()
    
    lazy var themeButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Switch to Night Mode", for: .normal)
        
        button.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
        
        contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(44.0)
            
            make.top.equalTo(stackView.snp.bottom).offset(36.0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(-36.0)
        }
        
        return button
    }()
    
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themeManager.themeChanged = { [weak self] _ in
            self?.setupColors()
        }
        
        renderCharts()
        setupColors()
    }
    
    private func renderCharts() {
        let chartsProps = datasets.map(makeProps(using:))
        chartsProps.forEach { props in
            let chartView = DetailedChartView()
            stackView.addArrangedSubview(chartView)
            chartView.render(props: props)
        }
    }
    
    private func makeProps(using dataset: Dataset) -> ChartView.Props {
        let lines = dataset.charts.map { chart in
            return Line(
                title: chart.name,
                xs: dataset.xs.dots,
                ys: chart.vector.dots,
                color: UIColor(hexString: chart.color))
        }
        return .init(lines: lines)
    }
    
    private func setupColors() {
        view.backgroundColor = colors.main
        
        navigationController?.navigationBar.barTintColor = colors.main
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: colors.title]
        
        label.textColor = colors.headline
        themeButton.backgroundColor = colors.view
        stackView.subviews.forEach { $0.backgroundColor = colors.view }
    }
    
    
    // MARK - Actions
    
    @objc private func changeTheme() {
        let newTheme: Theme = themeManager.currentTheme == .day ? .night : .day
        themeManager.currentTheme = newTheme
    }
}
