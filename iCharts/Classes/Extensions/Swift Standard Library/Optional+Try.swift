//
//  Optional+Try.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension Optional {
    
    func `try`(_ closure: ClosureWith<Wrapped>) {
        if let value = self {
            closure(value)
        }
    }
}
