//
//  Result.swift
//  iChartsDemo
//
//  Created by Volodymyr Hryhoriev on 3/11/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public enum Result<Value> {
    case success(Value)
    case failure(Error?)
    
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    public var isFailure: Bool {
        return !isSuccess
    }
    
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case let .failure(error):
            return error
        }
    }
    
    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }
}
