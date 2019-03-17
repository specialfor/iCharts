//
//  LineChartLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/13/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

import Foundation

final class LineChartLayer: CAShapeLayer {
    
    private var lineLayers: [LineLayer] {
        get { return (sublayers as? [LineLayer]) ?? [] }
        set { sublayers = newValue }
    }
    
    
    // MARK: - Init
    
    override init() {
        super.init()
        masksToBounds = true
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        masksToBounds = true
    }
    
    
    // MARK: - Render
    
    func render(props: Props) {
        CATransaction.performWithoutAnimation { _ in
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
        
        var chart = LinearChart(lines: props.lines)
        chart = normalizer.normalize(chart: chart, rectSize: props.rectSize)
        
//        CATransaction.animate(duration: 0.3) { _ in
            chart.lines.enumerated().forEach { index, line in
                let lineProps = LineLayer.Props(
//                    line: line)
                    line: line,
                    isAnimated: false)
                lineLayers[index].render(props: lineProps)
            }
//        }
    }
}

extension LineChartLayer {
    
    struct Props {
        let lines: [Line]
        let renderMode: RenderMode
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
