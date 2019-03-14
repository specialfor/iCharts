//
//  UIView+Constraints.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

extension UIView {
    
    func makeCosntraints(_ closure: () -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        closure().forEach { $0.isActive = true }
    }
}
