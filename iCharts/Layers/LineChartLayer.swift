//
//  LineChartLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Utils

final class LineChartLayer: CAShapeLayer {
    
    private var lineLayers: [LineLayer] {
        get { return (linesLayer.sublayers as? [LineLayer]) ?? [] }
        set { linesLayer.sublayers = newValue }
    }
    
    private let verticalLineLayer = VerticalLineLayer()
    private let linesLayer = CALayer()
    
    override init() {
        super.init()
        baseSetup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        baseSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseSetup()
    }
    
    private func baseSetup() {
        addSublayer(verticalLineLayer)
        addSublayer(linesLayer)
    }
    
    
    // MARK: - Render
    
    func render(props: Props) {
        renderVerticalLineLayer(props: props)
        renderLinesLayer(props: props)
    }
    
    private func renderVerticalLineLayer(props: Props) {
        let verticalLineLayerProps = VerticalLineLayer.Props(
            x: props.highlightedX,
            width: 1,
            color: UIColor(hexString: "#cfd1d2").cgColor,
            rectSize: props.rectSize)
        verticalLineLayer.render(props: verticalLineLayerProps)
    }
    
    private func renderLinesLayer(props: Props) {
        CATransaction.performWithoutAnimation { _ in
            masksToBounds = true
            frame = CGRect(origin: .zero, size: props.rectSize)
            adjustNumberOfLayers(props: props)
        }
        animate(props: props)
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
    }
    
    private func animate(props: Props) {
        let normalizer = NormalizerFactory().makeNormalizer(kind: props.renderMode.normalizerKind)
        var props = props
        props.lines = normalizer.normalize(lines: props.lines, rectSize: props.rectSize)
        renderNormalized(props: props)
    }
    
    private func renderNormalized(props: Props) {
        CATransaction.animate(duration: 0) { transaction in
//            let function = CAMediaTimingFunction(name: .linear)
//            transaction.setAnimationTimingFunction(function)
            
            props.lines.enumerated().forEach { index, line in
                let lineProps = LineLayer.Props(
                    line: line,
                    lineWidth: props.lineWidth)
                lineLayers[index].render(props: lineProps)
            }
        }
    }
}

extension LineChartLayer {
    
    struct Props {
        var lines: [Line]
        let lineWidth: CGFloat
        let renderMode: RenderMode
        let highlightedX: CGFloat?
        let rectSize: CGSize
        
        enum RenderMode {
            case scaleToFill
            case aspectFill
        }
    }
}

private extension LineChartLayer.Props.RenderMode {
    
    var normalizerKind: NormalizerFactory.Kind {
        return .init(renderMode: self)
    }
}

private extension NormalizerFactory.Kind {
    
    init(renderMode: LineChartLayer.Props.RenderMode) {
        switch renderMode {
        case .scaleToFill:
            self = .size
        case .aspectFill:
            self = .minLength(1)
        }
    }
}
