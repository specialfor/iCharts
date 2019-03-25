//
//  UIView+Constraints.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

extension UIView {
    
    func makeCosntraints(_ closure: () -> [NSLayoutConstraint]) {
        let constraints = closure()
        makeConstraints(constraints)
    }
    
    private func makeConstraints(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        constraints.forEach { $0.isActive = true }
    }
    
    func addSubview(_ view: UIView, constraintsMaker: (UIView) -> [NSLayoutConstraint]) {
        addSubview(view)
        let constraints = constraintsMaker(self)
        view.makeConstraints(constraints)
    }
    
    func edgesConstraints(to view: UIView) -> [NSLayoutConstraint] {
        return [
            verticalInsets(to: view),
            horizontalInsets(to: view)
            ].flatMap { $0 }
    }
    
    func verticalInsets(to view: UIView, inset: CGFloat = 0) -> [NSLayoutConstraint] {
        return [
            topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset)
        ]
    }
    
    func horizontalInsets(to view: UIView, inset: CGFloat = 0) -> [NSLayoutConstraint] {
        return [
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
        ]
    }
    
    func sizeConstraints(to view: UIView) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalTo: view.widthAnchor),
            heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
    }
}
