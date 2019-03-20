//
//  ChartInfoView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

private let cellIdentifier = "lol-kek-cheburek"

public final class ChartInfoView: View, UITableViewDataSource {
   
    private var props: Props?
    
    // MARK: - Subviews
    
    private lazy var dateMonthLabel: UILabel = {
        let label = UILabel()
        
        addSubview(label) { superview in
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)
            
            return [
                label.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 8.0),
                label.topAnchor.constraint(equalTo: superview.topAnchor, constant: 4.0)
            ]
        }
        
        return label
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        
        addSubview(label) { superview in
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)
            
            let bottomConstraint = label.bottomAnchor.constraint(greaterThanOrEqualTo: superview.bottomAnchor, constant: -4.0)
            bottomConstraint.priority = .defaultLow
            
            return [
                label.topAnchor.constraint(equalTo: dateMonthLabel.bottomAnchor),
                label.leadingAnchor.constraint(equalTo: dateMonthLabel.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: dateMonthLabel.trailingAnchor),
                bottomConstraint
            ]
        }
        
        return label
    }()
    
    private lazy var tableView: AutoSizableTableView = {
        let tableView = AutoSizableTableView()
        
        tableView.register(CellView.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        
        tableView.allowsSelection = false
        
        tableView.rowHeight = 20.0
        tableView.dataSource = self
        
        addSubview(tableView) { superview in
            return [
                tableView.topAnchor.constraint(equalTo: dateMonthLabel.topAnchor),
                tableView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -8.0),
                tableView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -4.0),
                tableView.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 8.0)
            ]
        }
        
        return tableView
    }()
    
    
    // MARK: - View
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    public override func baseSetup() {
        super.baseSetup()
        tableView.isHidden = false
        backgroundColor = UIColor(hexString: "#f2f2f7")
    }
    
    
    // MARK: - Render
    
    public func render(props: Props) {
        dateMonthLabel.text = props.dateMonth
        yearLabel.text = props.year
        self.props = props
        tableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props?.lineValues.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lineValue = props?.lineValues[indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CellView else {
                return UITableViewCell()
        }
        
        cell.setup(with: lineValue)
        
        return cell
    }
}


extension ChartInfoView {
    
    public struct Props {
        public let dateMonth: String
        public let year: String
        public let lineValues: [LineValue]
        
        public init(dateMonth: String, year: String, lineValues: [LineValue]) {
            self.dateMonth = dateMonth
            self.year = year
            self.lineValues = lineValues
        }
        
        public struct LineValue {
            public let value: String
            public let color: UIColor
            
            public init(value: String, color: UIColor) {
                self.value = value
                self.color = color
            }
        }
    }
}


extension ChartInfoView {
    
    final class CellView: UITableViewCell {
        
        lazy var label: UILabel = {
            let label = UILabel()
            
            label.textAlignment = .right
            
            addSubview(label) { superview in
                return label.edgesConstraints(to: superview)
            }
            
            return label
        }()
        
        func setup(with props: Props.LineValue) {
            backgroundColor = .clear
            
            label.text = props.value
            label.textColor = props.color
        }
    }
}
