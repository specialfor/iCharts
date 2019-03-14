//
//  Chart.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

public struct LinearChart {
    public var lines: [Line]
    
    public init(lines: [Line]) {
        self.lines = lines
    }
}
