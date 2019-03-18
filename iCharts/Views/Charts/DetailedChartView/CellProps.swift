//
//  File.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Utils

extension DetailedChartView {
    
    class CellProps {
        let title: Variable<String>
        let color: Variable<UIColor>
        let isChecked: Variable<Bool>
        
        init(title: String, color: UIColor, isChecked: Bool) {
            self.color = Variable(color)
            self.title = Variable(title)
            self.isChecked = Variable(isChecked)
        }
    }
}
