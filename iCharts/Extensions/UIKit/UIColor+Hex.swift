//
//  UIColor+Hex.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public extension UIColor {
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexint = Int(hexString.hexInt)
        
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

private extension String {
    
    var hexInt: UInt32 {
        var hexInt: UInt32 = 0
        
        let scanner: Scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt32(&hexInt)
        
        return hexInt
    }
}
