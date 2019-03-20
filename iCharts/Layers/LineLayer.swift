//
//  LineLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//


final class LineLayer: CAShapeLayer {
    
    func render(props: Props) {
        renderLinePath(props: props)
        renderCircleLayer(props: props)
    }
    
    private func renderLinePath(props: Props) {
        let path = makePath(using: props).cgPath
        
        let strokeColor = props.line.isHidden ? UIColor.clear.cgColor : props.line.color.cgColor
        let lineWidth = props.lineWidth
        
        if props.isAnimated {
            self.path = presentation()?.path
            self.strokeColor = presentation()?.strokeColor
            self.lineWidth = presentation()?.lineWidth ?? 1
            
            let animation = makeAnimation(path: path, strokeColor: strokeColor, lineWidth: lineWidth)
            add(animation, forKey: "animation")
        } else {
            self.path = path
            self.strokeColor = strokeColor
            self.lineWidth = lineWidth
        }
    }
    
    private func makePath(using props: Props) -> UIBezierPath {
        let path = UIBezierPath()
        
        let linePath = makePath(using: props.line)
        path.append(linePath)
        
        return path
    }
    
    private func makePath(using line: Line) -> UIBezierPath {
        let path = UIBezierPath()
        
        var points = line.points
        let first = points.removeFirst()
        
        path.move(to: first)
        points.forEach { path.addLine(to: $0) }
        
        return path
    }
    
    private func makeAnimation(path: CGPath, strokeColor: CGColor, lineWidth: CGFloat) -> CAAnimation {
        let group = CAAnimationGroup()
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = self.path
        pathAnimation.toValue = path
        self.path = path
        
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = self.strokeColor
        strokeColorAnimation.toValue = strokeColor
        self.strokeColor = strokeColor
        
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = self.lineWidth
        lineWidthAnimation.toValue = lineWidth
        self.lineWidth = lineWidth
        
        group.animations = [pathAnimation, strokeColorAnimation, lineWidthAnimation]
        
        return group
    }
    
    private func renderCircleLayer(props: Props) {
        sublayers = []
        guard let point = props.line.highlightedPoint else {
            return
        }
        
        let layer = makeCircleLayer(props: props, at: point)
        addSublayer(layer)
    }
    
    private func makeCircleLayer(props: Props, at point: CGPoint) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = props.line.color.cgColor
        
        layer.lineWidth = props.lineWidth
        layer.path = makeCircle(at: point, lineWidth: props.lineWidth).cgPath
        return layer
    }
    
    private func makeCircle(at point: CGPoint, lineWidth: CGFloat) -> UIBezierPath {
        let diametr = 3 * lineWidth
        let radius = 0.5 * diametr
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: diametr,
            height: diametr)
        return UIBezierPath(ovalIn: rect)
    }
}

extension LineLayer {
    
    struct Props {
        let line: Line
        let lineWidth: CGFloat
        let isAnimated: Bool
        
        init(line: Line, lineWidth: CGFloat, isAnimated: Bool = true) {
            self.line = line
            self.lineWidth = lineWidth
            self.isAnimated = isAnimated
        }
    }
}
