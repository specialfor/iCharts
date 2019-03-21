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

#if DEBUG
import GDPerformanceView_Swift
#endif

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
        
        #if DEBUG
        PerformanceMonitor.shared().start()
        #endif
        
        renderCharts()
        themeManager.themeChanged = { [weak self] theme in
            self?.setupColors()
            
            let opossiteTheme: Theme = theme == .day ? .night : .day
            let title = "Switch to \(opossiteTheme.rawValue.capitalized) Mode"
            self?.themeButton.setTitle(title, for: .normal)
        }
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
        stackView.subviews.forEach {
            $0.backgroundColor = colors.view
            ($0 as? DetailedChartView)?.colors = makeColorsForChart()
        }
    }
    
    private func makeColorsForChart() -> DetailedChartView.Colors {
        return DetailedChartView.Colors(
            chart: .init(
                chart: .init(
                    chart: .init(
                        labels: colors.caption,
                        horizontalLines: colors.separator,
                        lineChart: .init(
                            verticalLine: colors.boldSeparator,
                            circle: colors.view)),
                    chartInfo: .init(
                        background: colors.main,
                        title: colors.chartInfoTitle)),
                slider: .init(
                    overlay: colors.main.withAlphaComponent(0.5),
                    handler: colors.handler.withAlphaComponent(0.9))),
            title: colors.title,
            separator: colors.separator,
            selection: colors.selection)
    }
    
    
    // MARK - Actions
    
    @objc private func changeTheme() {
        let newTheme: Theme = themeManager.currentTheme == .day ? .night : .day
        themeManager.currentTheme = newTheme
    }
}
