//
//  XLabelsLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/19/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class XLabelsLayer: CALayer {
    
    var textColor: UIColor = .gray {
        didSet {
            (sublayers as? [CATextLayer])?.forEach { $0.foregroundColor = textColor.cgColor }
        }
    }
    
    func render(props: Props) {
        backgroundColor = UIColor.clear.cgColor
        frame = props.rect
        
        renderLabels(props: props)
    }
    
    private func renderLabels(props: Props) {
        sublayers = props.labels.map {
            makeTextLayer(
                label: $0,
                labelWidth: props.labelWidth)
        }
    }
    
    private func makeTextLayer(label: Props.Label, labelWidth: CGFloat) -> CATextLayer {
        let fontSize: CGFloat = 12.0
        
        let layer = CATextLayer(string: label.value, textColor: textColor.cgColor, fontSize: fontSize)
        
        layer.frame.size.width = labelWidth
        
        layer.frame.origin.x += label.point.x
        layer.frame.origin.y += frame.size.height / 2 - fontSize / 2
        
        return layer
    }
}

extension XLabelsLayer {
    
    struct Props {
        let labels: [Label]
        let labelWidth: CGFloat
        let rect: CGRect
        
        struct Label {
            let point: CGPoint
            let value: String
        }
    }
}
