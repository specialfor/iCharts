//
//  NormalizerFactory.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import CoreGraphics

final class NormalizerFactory {
    
    enum Kind {
        case size(CGSize)
        case minLength(CGFloat)
    }
    
    func makeNormalizer(kind: Kind) -> Normalizer {
        switch kind {
        case let .size(size):
            return SizeNormalizer(size: size)
        case let .minLength(length):
            return MinLengthNormalizer(length: length)
        }
    }
}
