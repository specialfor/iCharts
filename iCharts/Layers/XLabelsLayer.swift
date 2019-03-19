//
//  XLabelsLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/19/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class XLabelLayer: CALayer {
    
    func render(props: Props) {
        backgroundColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)
        
        renderLabels(props: props)
    }
    
    private func renderLabels(props: Props) {
        sublayers = props.labels.map { makeTextLayer(label: $0, textColor: props.textColor) }
    }
    
    private func makeTextLayer(label: Props.Label, textColor: CGColor) -> CATextLayer {
        let layer = CATextLayer(string: label.value, textColor: textColor)
        layer.frame.origin.x += label.point.x
        return layer
    }
}

extension XLabelLayer {
    
    struct Props {
        let labels: [Label]
        let textColor: CGColor
        let rectSize: CGSize
        
        struct Label {
            let point: CGPoint
            let value: String
        }
    }
}
