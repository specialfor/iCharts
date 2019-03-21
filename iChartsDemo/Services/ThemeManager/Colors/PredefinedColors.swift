//
//  PredefinedColors.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/21/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

extension Colors {
    
    static let day = Colors(
        main: .init(hexString: "#efeff4"),
        view: .init(hexString: "#fefefe"),
        cellTitleText: .init(hexString: "#000000"),
        titleText: .init(hexString: "#6d6d72"),
        chartInfoText: .init(hexString: "#6d6d72"),
        captionText: .init(hexString: "#989ea3"),
        separator: .init(hexString: "#f3f3f3"),
        boldSeparator: .init(hexString: "#cfd1d2"))
    
    static let night = Colors(
        main: .init(hexString: "#18222d"),
        view: .init(hexString: "#212f3f"),
        cellTitleText: .init(hexString: "#fefefe"),
        titleText: .init(hexString: "#5b6b7f"),
        chartInfoText: .init(hexString: "#fefefe"),
        captionText: .init(hexString: "#5b6b7f"),
        separator: .init(hexString: "#1b2734"),
        boldSeparator: .init(hexString: "#131b23"))
}
