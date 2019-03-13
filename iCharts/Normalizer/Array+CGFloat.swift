//
//  Array+CGFloat.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

extension Array where Element == CGFloat {
    
    func factored(by factor: CGFloat) -> Array {
        return map { $0 / factor }
    }
}

