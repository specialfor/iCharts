//
//  LineLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//


final class LineLayer: CAShapeLayer {
    
    var circleColor: UIColor = .white {
        didSet { circleLayer.fillColor = circleColor.cgColor }
    }
    
    private let circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    override init() {
        super.init()
        addSublayer(circleLayer)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Render
    
    func render(props: Props) {
        renderLinePath(props: props)
        renderCircleLayer(props: props)
    }
    
    private func renderLinePath(props: Props) {
        let path = makePath(using: props).cgPath
        animate(layer: self, path: path, props: props)
    }
    
    private func animate(layer: CAShapeLayer,
                         path: CGPath?,
                         props: Props,
                         fillColor: CGColor = UIColor.clear.cgColor) {
        
        let strokeColor = props.line.color.cgColor
        let lineWidth = props.lineWidth
        
        if props.isAnimated {
            layer.path = layer.presentation()?.path
            layer.strokeColor = layer.presentation()?.strokeColor
            layer.lineWidth = layer.presentation()?.lineWidth ?? 1
            layer.fillColor = layer.presentation()?.fillColor
            
            let animation = makeAnimation(layer: layer,
                                          path: path,
                                          strokeColor: strokeColor,
                                          lineWidth: lineWidth,
                                          fillColor: fillColor)
            layer.add(animation, forKey: "\(layer.hash)")
        } else {
            layer.path = path
            layer.strokeColor = strokeColor
            layer.lineWidth = lineWidth
            layer.fillColor = fillColor
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
    
    private func makeAnimation(layer: CAShapeLayer,
                               path: CGPath?,
                               strokeColor: CGColor,
                               lineWidth: CGFloat,
                               fillColor: CGColor) -> CAAnimation {
        
        let group = CAAnimationGroup()
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = layer.path
        pathAnimation.toValue = path
        layer.path = path
        
        let strokeColorAnimation = CABasicAnimation(keyPath: "strokeColor")
        strokeColorAnimation.fromValue = layer.strokeColor
        strokeColorAnimation.toValue = strokeColor
        layer.strokeColor = strokeColor
        
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.fromValue = layer.lineWidth
        lineWidthAnimation.toValue = lineWidth
        layer.lineWidth = lineWidth
        
        let fillColorAnimation = CABasicAnimation(keyPath: "fillColor")
        fillColorAnimation.fromValue = layer.fillColor
        fillColorAnimation.toValue = fillColor
        layer.fillColor = fillColor
        
        group.animations = [pathAnimation, strokeColorAnimation, lineWidthAnimation, fillColorAnimation]
        
        return group
    }
    
    private func renderCircleLayer(props: Props) {
        var props = props
        
        let path: UIBezierPath?
        if let point = props.line.highlightedPoint {
            path = makeCircle(at: point, lineWidth: props.lineWidth)
        } else {
            props.isAnimated = true
            path = nil
        }
        
        animate(layer: circleLayer, path: path?.cgPath, props: props, fillColor: circleColor.cgColor)
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
        var isAnimated: Bool
        
        init(line: Line, lineWidth: CGFloat, isAnimated: Bool = true) {
            self.line = line
            self.lineWidth = lineWidth
            self.isAnimated = isAnimated
        }
    }
}
