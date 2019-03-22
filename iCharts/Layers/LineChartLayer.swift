//
//  LineChartLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Utils

public final class LineChartLayer: CAShapeLayer {
    
    private var lineLayers: [LineLayer] {
        get { return (linesLayer.sublayers as? [LineLayer]) ?? [] }
        set { linesLayer.sublayers = newValue }
    }
    
    private let verticalLineLayer = VerticalLineLayer()
    private let linesLayer = CALayer()
    
    public var colors: Colors = .initial {
        didSet { setupColors() }
    }
    
    private func setupColors() {
        verticalLineLayer.lineColor = colors.verticalLine
        lineLayers.forEach { $0.circleColor = colors.circle }
    }
    
    private var props: Props?
    
    
    // MARK: - Init
    
    public override init() {
        super.init()
        baseSetup()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        baseSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseSetup()
    }
    
    private func baseSetup() {
        addSublayer(verticalLineLayer)
        addSublayer(linesLayer)
        setupColors()
    }
    
    
    // MARK: - Render
    
    public func render(props: Props) {
        renderVerticalLineLayer(props: props)
        renderLinesLayer(props: props)
        self.props = props
    }
    
    private func renderVerticalLineLayer(props: Props) {
        let verticalLineLayerProps = VerticalLineLayer.Props(
            x: props.highlightedX,
            width: 1,
            rectSize: props.rectSize)
        
        animate(props: props) { props in
            verticalLineLayer.render(props: verticalLineLayerProps)
        }
    }
    
    private func renderLinesLayer(props: Props) {
        CATransaction.performWithoutAnimation { _ in
            masksToBounds = true
            frame = CGRect(origin: .zero, size: props.rectSize)
        }
        adjustNumberOfLayers(props: props)
        
        let props = normalized(props: props)
        animate(props: props) { props in
            props.lines.enumerated().forEach { index, line in
                let lineProps = LineLayer.Props(
                    line: line,
                    lineWidth: props.lineWidth)
                lineLayers[index].render(props: lineProps)
            }
        }
    }
    
    private func adjustNumberOfLayers(props: Props) {
        let layersCount = lineLayers.count
        let linesCount = props.lines.count
        
        if layersCount < linesCount {
            (0..<linesCount - layersCount).forEach { _ in
                let layer = LineLayer()
                layer.fillColor = UIColor.clear.cgColor
                lineLayers.append(layer)
            }
        } else if layersCount > linesCount {
            lineLayers = Array(lineLayers.dropLast(layersCount - linesCount))
        }
        setupColors()
    }
    
    private func normalized(props: Props) -> Props {
        let normalizer = SizeNormalizer(isInFullSize: props.isInFullSize)
        var props = props
        props.lines = normalizer.normalize(lines: props.lines, rectSize: props.rectSize)
        return props
    }
    
    private func animate(props: Props, closure: (Props) -> Void) {
        let duration = animatationDuration(props: props)
        
        CATransaction.animate(duration: duration) { _ in
            closure(props)
        }
    }
    
    private func animatationDuration(props: Props) -> CFTimeInterval {
        let duration: TimeInterval
        
        if let oldProps = self.props {
            if props.lines.count != oldProps.lines.count {
                duration = 0.3
            } else if oldProps.highlightedX != nil, props.highlightedX == nil {
                duration = 0.3
            } else {
                duration = 0
            }
        } else {
            duration = 0
        }
        
        return duration
    }
}

extension LineChartLayer {
    
    public struct Colors {
        public let verticalLine: UIColor
        public let circle: UIColor

        public init(verticalLine: UIColor, circle: UIColor) {
            self.verticalLine = verticalLine
            self.circle = circle
        }
        
        public static let initial = Colors(verticalLine: .darkGray, circle: .white)
    }
    
    public struct Props {
        var lines: [Line]
        let lineWidth: CGFloat
        let highlightedX: CGFloat?
        let isInFullSize: Bool
        let rectSize: CGSize
    }
}
