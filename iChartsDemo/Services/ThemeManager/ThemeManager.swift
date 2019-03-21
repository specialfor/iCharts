//
//  ThemeManager.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/21/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

private let userDefaults = UserDefaults.standard
private let themeKey = "iChartsDemo-theme-key"

final class ThemeManager {
    
    var themeChanged: ((Theme) -> Void)? {
        didSet { themeChanged?(currentTheme) }
    }
    
    var currentTheme: Theme {
        get {
            let rawTheme = userDefaults.string(forKey: themeKey)
            return rawTheme.flatMap { Theme(rawValue: $0) } ?? .day
        }
        set {
            guard currentTheme != newValue else {
                return
            }
            
            userDefaults.set(newValue.rawValue, forKey: themeKey)
            userDefaults.synchronize()
            
            themeChanged?(newValue)
        }
    }
}
