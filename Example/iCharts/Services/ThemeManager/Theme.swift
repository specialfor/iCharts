//
//  Theme.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/21/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

enum Theme: String {
    case day
    case night
    
    var colors: ThemeColors {
        switch self {
        case .day:
            return .day
        case .night:
            return .night
        }
    }
}
