//
//  zipInto.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

func zip<S1, S2, T>(_ seq1: S1, _ seq2: S2, maker: (S1.Element, S2.Element) -> T) -> [T] where S1: Sequence, S2: Sequence {
    return zip(seq1, seq2).map(maker)
}

func zipToPoints(_ xs: [CGFloat], _ ys: [CGFloat]) -> [CGPoint] {
    return zip(xs, ys) { CGPoint(x: $0, y: $1) }
}
