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
    
    func render(props: Props) {
        adjustNumberOfLayers(props: props)
        animate(props: props)
    }
    
    private func adjustNumberOfLayers(props: Props) {
        let layersCount = lineLayers.count
        let linesCount = props.lines.count
        
        if layersCount < linesCount {
            (0..<linesCount - layersCount).forEach { _ in
                let layer = LineLayer() // TODO: need to think
                layer.fillColor = UIColor.clear.cgColor
                lineLayers.append(layer)
            }
        } else if layersCount > linesCount {
            lineLayers = Array(lineLayers.dropLast(layersCount - linesCount))
        }
    }
    
    private func animate(props: Props) {
//        CATransaction.animate(duration: 3) { _ in
//            props.lines.enumerated().forEach { index, line in
//                let lineProps = LineLayer.Props(line: line, renderMode: props.renderMode)
//                lineLayers[index].render(props: lineProps)
////                lineLayers[index].render(props: lineProps, animated: false)
//            }
//        }
        CATransaction.animate(duration: 1, job: { _ in
            props.lines.enumerated().forEach { index, line in
                let lineProps = LineLayer.Props(line: line, renderMode: props.renderMode)
                lineLayers[index].render(props: lineProps)
                //                lineLayers[index].render(props: lineProps, animated: false)
            }
        }) {
            print("animation ended")
        }
    }
}

extension LineChartLayer {
    typealias RenderMode = LineLayer.Props.RenderMode
    
    struct Props {
        let lines: [Line]
        let renderMode: RenderMode
    }
}
