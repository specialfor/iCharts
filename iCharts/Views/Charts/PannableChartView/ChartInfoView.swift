//
//  ChartInfoView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

private let cellIdentifier = "lol-kek-cheburek"

public final class ChartInfoView: View {
   
    private var props: Props?
    
    public var colors: Colors = .initial {
        didSet { setupColors() }
    }
    
    private func setupColors() {
        backgroundColor = colors.background
        dateMonthLabel.textColor = colors.title
        yearLabel.textColor = colors.title
    }
    
    // MARK: - Subviews
    
    private lazy var dateMonthLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        
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
        
        label.font = UIFont.systemFont(ofSize: 12.0)
        
        addSubview(label) { superview in
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.setContentHuggingPriority(.required, for: .vertical)
            
            let bottomConstraint = label.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -4.0)
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.distribution = .equalSpacing
        
        addSubview(stackView) { superview in
            let bottomConstraint =  stackView.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor, constant: -4.0)
            
            return [
                stackView.topAnchor.constraint(equalTo: dateMonthLabel.topAnchor),
                stackView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -8.0),
                stackView.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 16.0),
                bottomConstraint
            ]
        }
        
        return stackView
    }()
    
    
    // MARK: - View
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
    }
    
    public override func baseSetup() {
        super.baseSetup()
        stackView.isHidden = false
        setupColors()
    }
    
    
    // MARK: - Render
    
    public func render(props: Props) {
        dateMonthLabel.text = props.dateMonth
        yearLabel.text = props.year
        renderStackView(props: props)
    }
    
    private func renderStackView(props: Props) {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        
        props.lineValues
            .map(makeLabel(using: ))
            .forEach { stackView.addArrangedSubview($0) }
    }
    
    private func makeLabel(using props: Props.LineValue) -> UILabel {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.text = props.value
        label.textColor = props.color
        label.textAlignment = .right
        
        return label
    }
}


extension ChartInfoView {
    
    public struct Colors {
        public let background: UIColor
        public let title: UIColor

        public init(background: UIColor, title: UIColor) {
            self.background = background
            self.title = title
        }
        
        public static let initial = Colors(background: .white, title: .black)
    }
    
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
        
        private var size: CGSize = .zero {
            didSet { invalidateIntrinsicContentSize() }
        }
        
        override var intrinsicContentSize: CGSize {
            return size
        }
        
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
            
            label.sizeToFit()
            size = label.frame.size
        }
    }
}
