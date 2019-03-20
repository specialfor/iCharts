//
//  VerticalLineLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/20/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

final class VerticalLineLayer: CAShapeLayer {
    
    func render(props: Props) {
        frame.size = props.rectSize
        backgroundColor = nil
        strokeColor = props.color
        lineWidth = props.width
        path = makePath(x: props.x, rectSize: props.rectSize)
    }
    
    private func makePath(x: CGFloat?, rectSize: CGSize) -> CGPath? {
        guard let x = x else {
            return nil
        }
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: rectSize.height))
        
        return path.cgPath
    }
}

extension VerticalLineLayer {
    
    struct Props {
        let x: CGFloat?
        let width: CGFloat
        let color: CGColor
        let rectSize: CGSize
    }
}
