//
//  GridLayer.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/18/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

final class GridLayer: CAShapeLayer {
    
    func render(props: Props) {
        fillColor = UIColor.clear.cgColor
        frame = CGRect(origin: .zero, size: props.rectSize)
        
        renderLines(lines: props.lines)
    }
    
    private func renderLines(lines: Props.Lines?) {
        guard let lines = lines else { return }
        
        sublayers = makeLayers(lines: lines)
    }
    
    private func makeLayers(lines: Props.Lines) -> [CALayer] {
        let count = lines.yLabels.count
        let space = frame.height / CGFloat(count)
        
        return lines.yLabels.enumerated().map { index, label in
            let y = CGFloat(index + 1) * space
            let point = CGPoint(x: frame.maxX, y: y)
            return makeLayer(point: point, lines: lines, label: label)
        }
    }
    
    private func makeLayer(point: CGPoint, lines: Props.Lines, label: String) -> CALayer {
        let layer = CALayer()
        
        layer.frame = frame
        layer.backgroundColor = UIColor.clear.cgColor
        
        layer.addSublayer(makePathLayer(point: point, color: lines.lineColor))
        layer.addSublayer(makeTextLayer(point: point, color: lines.textColor, label: label))
        
        return layer
    }
    
    private func makePathLayer(point: CGPoint, color: CGColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.backgroundColor = UIColor.clear.cgColor
        
        layer.path = makePath(point: point)
        layer.strokeColor = color
        
        return layer
    }
    
    private func makePath(point: CGPoint) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: point.y))
        path.addLine(to: point)
        return path.cgPath
    }
    
    private func makeTextLayer(point: CGPoint, color: CGColor, label: String) -> CATextLayer {
        let layer = CATextLayer()
        
        layer.backgroundColor = UIColor.clear.cgColor

        let fontSize: CGFloat = 12.0
        let attributedString = NSAttributedString(string: label, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor(cgColor: color)
            ])
        
        layer.string = attributedString
        layer.alignmentMode = .left
        layer.contentsScale = UIScreen.main.scale
        
        let eps = fontSize * 0.2
        
        var rect = (label as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: fontSize), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
        rect.size.width *= 2
        rect.size.height += eps
        rect.origin = CGPoint(x: 0, y: point.y - (rect.height + eps))

        layer.frame = rect
        
        return layer
    }
}

extension GridLayer {
    
    struct Props {
        let lines: Lines?
        let rectSize: CGSize
        
        struct Lines {
            let yLabels: [String]
            let lineColor: CGColor
            let textColor: CGColor
        }
    }
}
