//
//  HandlerView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

private let verticalInset: CGFloat = 1
private let _horizontalInset: CGFloat = 10
private let withoutArrowsHorizontalinset: CGFloat = 4
private let arrowHorizontalInset: CGFloat = 3

private let minimumTouchWidth: CGFloat = 22

public final class HandlerView: View {
    
    public var borderColor: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    
    public var shouldDrawArrows: Bool = true {
        didSet { setNeedsDisplay() }
    }
    
    private var horizontalInset: CGFloat {
        if shouldDrawArrows {
            return _horizontalInset
        } else {
            return withoutArrowsHorizontalinset
        }
    }
    
    public var innerFrame: CGRect {
        return self.innerRect(for: frame)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 64.0, height: 44.0)
    }
    
    override func baseSetup() {
        super.baseSetup()
        contentMode = .redraw
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawBorder(in: rect, context: context)
        if shouldDrawArrows {
            drawArrows(in: rect, context: context)
        }
    }
    
    private func drawBorder(in rect: CGRect, context: CGContext) {
        context.saveGState()
        
        let color = borderColor.cgColor
        context.setStrokeColor(color)
        context.setFillColor(color)
        
        let path = border(for: rect)
        path.stroke()
        path.fill()
        
        context.restoreGState()
    }
    
    private func drawArrows(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(2)
        
        context.addPath(arrowPath(in: rect, reversed: false))
        context.strokePath()
        
        context.addPath(arrowPath(in: rect, reversed: true))
        context.strokePath()
    }
    
    private func arrowPath(in rect: CGRect, reversed isReversed: Bool) -> CGPath {
        let width: CGFloat = horizontalInset - 2 * arrowHorizontalInset
        let height: CGFloat = 2.5 * width
        
        let midX: CGFloat = 5 // TODO: need to change
        let midY = rect.midY
        
        let maxX = midX + width / 2
        let minX = midX - width / 2
        
        let maxY = midY + height / 2
        let minY = midY - height / 2
        
        let path = CGMutablePath()
        
        let rectWidth = rect.size.width
        if !isReversed {
            path.move(to: CGPoint(x: maxX, y: minY))
            path.addLine(to: CGPoint(x: minX, y: midY))
            path.addLine(to: CGPoint(x: maxX, y: maxY))
        } else {
            path.move(to: CGPoint(x: rectWidth - maxX, y: minY))
            path.addLine(to: CGPoint(x: rectWidth - minX, y: midY))
            path.addLine(to: CGPoint(x: rectWidth - maxX, y: maxY))
        }
        
        return path
    }
    
    private func border(for rect: CGRect) -> UIBezierPath {
        let innerRect = self.innerRect(for: rect)
        
        let path = UIBezierPath(rect: innerRect)
        let outerPath = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        path.append(outerPath)
        path.usesEvenOddFillRule = true
        
        return path
    }
    
    private func innerRect(for rect: CGRect) -> CGRect {
        let origin = rect.origin
        let size = rect.size
        
        return CGRect(x: origin.x + horizontalInset,
                               y: origin.y + verticalInset,
                               width: size.width - 2 * horizontalInset,
                               height: size.height - 2 * verticalInset)
    }
    
    
    // MARK: - Hit Test
    
    func touchPosition(point: CGPoint) -> TouchPosition {
        let touchWidth = minimumTouchWidth / 2
        let horizontalInset = self.horizontalInset
        
        let leftStartBound = -(touchWidth - horizontalInset)
        let leftEndBound = touchWidth + horizontalInset
        let rightStartBound = bounds.width - leftEndBound
        let rightEndBound = bounds.width - leftStartBound
        
        switch point.x {
        case leftStartBound...leftEndBound:
            return .left
        case leftEndBound...rightStartBound:
            return .inside
        case rightStartBound...rightEndBound:
            return .right
        default:
            return .outside
        }
    }
}

extension HandlerView {
    
    enum TouchPosition {
        case left
        case right
        case inside
        case outside
        
        static var expandablePositions: [TouchPosition] {
            return [.left, .right]
        }
    }
}
