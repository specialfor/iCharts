//
//  CATransaction+Animate.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import QuartzCore

extension CATransaction {
    typealias Completion = () -> Void
    typealias Job = (CATransaction.Type) -> Void
    
    static func animate(duration: CFTimeInterval, job: Job) {
        animate(duration: duration, job: job, completion: nil)
    }
    
    static func animate(duration: CFTimeInterval, job: Job, completion: Completion?) {
        perform { transaction in
            transaction.setAnimationDuration(duration)
            transaction.setCompletionBlock(completion)
            job(transaction)
        }
    }
    
    static func performWithoutAnimation(_ job: Job) {
        perform { transaction in
            transaction.setDisableActions(true)
            job(transaction)
        }
    }
    
    static func perform(_ job: Job) {
        CATransaction.begin()
        job(self)
        CATransaction.commit()
    }
}

