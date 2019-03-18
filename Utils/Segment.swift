//
//  Segment.swift
//  Utils
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public struct Segment<T> {
    public let from: T
    public let to: T
    
    public init(from: T, to: T) {
        self.from = from
        self.to = to
    }
}
