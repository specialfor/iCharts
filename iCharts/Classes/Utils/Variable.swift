//
//  Variable.swift
//  Utils
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public final class Variable<T> {
    
    public var value: T {
        didSet { closure?(value) }
    }
    
    private var closure: ClosureWith<T>? {
        didSet { closure?(value) }
    }
    
    public init(_ value: T){
        self.value = value
    }
    
    public func bind(_ closure: @escaping ClosureWith<T>) {
        self.closure = closure
    }
}
