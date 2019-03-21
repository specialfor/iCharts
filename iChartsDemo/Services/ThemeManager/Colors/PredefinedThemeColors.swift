//
//  PredefinedThemeColors.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/21/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension ThemeColors {
    
    static let day = ThemeColors(
        main: .init(hexString: "#efeff4"),
        view: .init(hexString: "#fefefe"),
        title: .init(hexString: "#000000"),
        headline: .init(hexString: "#6d6d72"),
        chartInfoTitle: .init(hexString: "#6d6d72"),
        caption: .init(hexString: "#989ea3"),
        separator: .init(hexString: "#f3f3f3"),
        boldSeparator: .init(hexString: "#cfd1d2"),
        handler: .init(hexString: "#cad4de"),
        selection: .init(hexString: "#f3f3f3"),
        isDarkNavigationBar: false)
    
    static let night = ThemeColors(
        main: .init(hexString: "#18222d"),
        view: .init(hexString: "#212f3f"),
        title: .init(hexString: "#fefefe"),
        headline: .init(hexString: "#5b6b7f"),
        chartInfoTitle: .init(hexString: "#fefefe"),
        caption: .init(hexString: "#5b6b7f"),
        separator: .init(hexString: "#1b2734"),
        boldSeparator: .init(hexString: "#131b23"),
        handler: .init(hexString: "#354659"),
        selection: .init(hexString: "#1b2734"),
        isDarkNavigationBar: true)
}
