//
//  LineLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//


final class LineLayer: CAShapeLayer {

    func render(props: Props) {
        let path = makePath(using: props.line).cgPath
        let strokeColor = props.line.color.cgColor
        
        if props.isAnimated {
            self.path = presentation()?.path
            self.strokeColor = presentation()?.strokeColor
            
            let animation = makeAnimation(path: path, strokeColor: strokeColor)
            add(animation, forKey: "animation")
        } else {
            self.path = path
            self.strokeColor = strokeColor
        }
    }
    
    private func makePath(using line: Line) -> UIBezierPath {
        let path = UIBezierPath()
        
        var points = line.points
        let first = points.removeFirst()
        
        path.move(to: first)
        points.forEach { path.addLine(to: $0) }
        
        return path
    }
    
    private func makeAnimation(path: CGPath, strokeColor: CGColor) -> CAAnimation {
        let group = CAAnimationGroup()
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = self.path
        pathAnimation.toValue = path
        self.path = path
        
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = self.strokeColor
        strokeColorAnimation.toValue = strokeColor
        self.strokeColor = strokeColor
        
        group.animations = [pathAnimation, strokeColorAnimation]
        
        return group
    }
}

extension LineLayer {
    
    struct Props {
        let line: Line
        let isAnimated: Bool
        
        init(line: Line, isAnimated: Bool = true) {
            self.line = line
            self.isAnimated = isAnimated
        }
    }
}
