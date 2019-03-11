//
//  Dataset.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

struct Dataset {
    let xs: Vector
    let charts: [Chart]
}

extension Dataset {
    
    struct Vector {
        let label: String
        let dots: [CGFloat]
    }
}

extension Dataset {
    
    struct Chart {
        let name: String
        let vector: Vector
        let color: String // hex (#00ff00)
        let kind: Kind
    }
}

extension Dataset.Chart {
    
    enum Kind: String {
        case line
    }
}
