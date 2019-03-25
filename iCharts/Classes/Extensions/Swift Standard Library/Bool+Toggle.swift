//
//  Bool+Toggle.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

extension Bool {
    
    mutating func toggle() {
        self = !self
    }
}
