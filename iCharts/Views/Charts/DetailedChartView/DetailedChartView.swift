//
//  DetailedChartView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

private let cellIdentifier = "lol-kek-cheburek"

public final class DetailedChartView: View {
    
    override var activateViews: [UIView] {
        return [tableView]
    }
    
    private var cellProps: [CellProps] = [] {
        didSet {
            datasource.props = cellProps
            delegate.props = cellProps
        }
    }
    private var props: ChartView.Props?
    
    
    // MARK: - Subviews
    
    private lazy var chartView: ChartScrollView = {
        let view = ChartScrollView()

        addSubview(view) { superview in
            var constraints = view.horizontalInsets(to: superview, inset: 16)
            constraints.append(view.topAnchor.constraint(equalTo: superview.topAnchor))
            constraints.append(view.heightAnchor.constraint(equalToConstant: 360))
            return constraints
        }
        
        return view
    }()
    
    private let datasource = Datasource(props: [], identifier: cellIdentifier)
    private let delegate = Delegate()
    
    private lazy var tableView: AutoSizableTableView = {
        let tableView = AutoSizableTableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.isScrollEnabled = false
        tableView.rowHeight = 44.0
        
        tableView.dataSource = datasource
        tableView.delegate = delegate
        
        addSubview(tableView) { superview in
            var constraints = tableView.horizontalInsets(to: superview)
            constraints.append(tableView.topAnchor.constraint(equalTo: chartView.bottomAnchor, constant: 16))
            constraints.append(tableView.bottomAnchor.constraint(equalTo: superview.bottomAnchor))
            return constraints
        }
        
        return tableView
    }()
    
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard let props = props else { return }
        chartView.render(props: props)
    }
    
    
    // MARK: - Render
    
    public func render(props: ChartView.Props) {
        self.props = props
        cellProps = props.chart.lines.map { CellProps(
            title: $0.title,
            color: $0.color,
            isChecked: true) }
        setNeedsLayout()
    }
}
