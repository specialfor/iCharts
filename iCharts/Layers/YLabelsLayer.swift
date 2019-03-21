//
//  YLabelsLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/19/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class YLabelsLayer: CALayer {
    
    var textColor: UIColor = .gray {
        didSet {
            (sublayers as? [CATextLayer])?.forEach { $0.foregroundColor = textColor.cgColor }
        }
    }
    
    func render(props: Props) {
        backgroundColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)
        
        renderLabels(props: props)
    }
    
    private func renderLabels(props: Props) {
        sublayers = props.labels.map { makeTextLayer(label: $0) }
    }
    
    private func makeTextLayer(label: Props.Label) -> CATextLayer {
        let fontSize: CGFloat = 12.0
        let layer = CATextLayer(string: label.value, textColor: textColor.cgColor, fontSize: fontSize)
        
        let eps = fontSize * 0.2
        layer.frame.size.width *= 2
        layer.frame.size.height += eps
        layer.frame.origin = CGPoint(x: 0, y: label.point.y - (layer.frame.size.height + eps))
        
        return layer
    }
}

extension YLabelsLayer {
    
    struct Props {
        let labels: [Label]
        let rectSize: CGSize
        
        struct Label {
            let point: CGPoint
            let value: String
        }
    }
}
