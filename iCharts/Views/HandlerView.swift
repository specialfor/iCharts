//
//  HandlerView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public final class HandlerView: View {
    
    private let verticalInset: CGFloat = 2
    private let horizontalInset: CGFloat = 10
    private let arrowHorizontalInset: CGFloat = 3
    private let borderColor = UIColor(hexString: "#cad4de")
    
    override func baseSetup() {
        super.baseSetup()
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        drawBorder(in: rect, context: context)
        drawArrows(in: rect, context: context)
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
        
        print(path)
    
        return path
    }
    
    private func border(for rect: CGRect) -> UIBezierPath {
        let origin = rect.origin
        let size = rect.size
        
        let innerRect = CGRect(x: origin.x + horizontalInset,
                      y: origin.y + verticalInset,
                      width: size.width - 2 * horizontalInset,
                      height: size.height - 2 * verticalInset)
        
        let path = UIBezierPath(rect: innerRect)
        let outerPath = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        path.append(outerPath)
        path.usesEvenOddFillRule = true
        
        return path
    }
}
