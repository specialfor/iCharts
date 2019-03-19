//
//  YLabelsLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/19/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class YLabelsLayer: CAShapeLayer {
    
    func render(props: Props) {
        fillColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)
        
        renderLabels(props: props)
    }
    
    private func renderLabels(props: Props) {
        sublayers = props.labels.map { makeTextLayer(label: $0, textColor: props.textColor) }
    }
    
    private func makeTextLayer(label: Props.Label, textColor: CGColor) -> CATextLayer {
        let layer = CATextLayer()
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        let string = label.value
        
        let fontSize: CGFloat = 12.0
        let attributedString = NSAttributedString(string: string, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor(cgColor: textColor)
            ])
        
        layer.string = attributedString
        layer.alignmentMode = .left
        layer.contentsScale = UIScreen.main.scale
        
        let eps = fontSize * 0.2
        
        var rect = (string as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: fontSize), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
        rect.size.width *= 2
        rect.size.height += eps
        rect.origin = CGPoint(x: 0, y: label.point.y - (rect.height + eps))
        
        layer.frame = rect
        
        return layer
    }
}

extension YLabelsLayer {
    
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
