//
//  ExpandableSliderView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

public final class ExpandableSliderView: UIControl {
    
    private let minWidth: CGFloat = 64
    
    private var widthConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    
    lazy var handlerView: HandlerView = {
        let view = HandlerView()

        addSubview(view)
        view.makeCosntraints {
            widthConstraint = view.widthAnchor.constraint(equalToConstant: minWidth)
            leadingConstraint = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
            
            return [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                leadingConstraint,
                widthConstraint
            ]
        }
        
        return view
    }()
    
    lazy var overlayView: UIView = {
        let view = UIView()
        
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        // TODO: copy paste
        addSubview(view)
        view.makeCosntraints {
            return [
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.topAnchor.constraint(equalTo: contentView.topAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ]
        }
        
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        
        addSubview(view)
        view.makeCosntraints {
            return [
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.topAnchor.constraint(equalTo: topAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        }
        
        return view
    }()
    
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseSetup()
    }
    
    func baseSetup() {
        [contentView, overlayView, handlerView].forEach { $0.isUserInteractionEnabled = false }
    }
    
    
    // MARK: - Handle tracking
    
    var touchPosition: HandlerView.TouchPosition = .outside
    var previousPoint: CGPoint!
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: handlerView)
        touchPosition = handlerView.touchPosition(point: point)
        
        previousPoint = touch.location(in: self)
        
        return touchPosition != .outside
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        
        if touchPosition == .inside {
            moveHandler(to: point)
        } else {
            changeHandlerWidth(using: point)
        }
        
        previousPoint = point
        
        return true
    }
    
    private func moveHandler(to point: CGPoint) {
        let delta = point.x - previousPoint.x
        leadingConstraint.constant = leadingInset(using: delta)
    }
    
    private func leadingInset(using delta: CGFloat) -> CGFloat {
        let leadingInset = leadingConstraint.constant + delta
        let minBound: CGFloat = 0
        let maxBound = bounds.width - widthConstraint.constant
        return min(max(minBound, leadingInset), maxBound)
    }
    
    private func changeHandlerWidth(using point: CGPoint) {
        let isRightDirection = (point.x - previousPoint.x) > 0
        
        if touchPosition == .left, isRightDirection, widthConstraint.constant == minWidth {
            return
        }
        
        let delta = self.delta(using: point)
        
        if touchPosition == .left {
            leadingConstraint.constant = leadingInsetForLeftTouchPosition(using: -delta)
        }
        
        widthConstraint.constant = self.width(using: delta)
    }
    
    private func delta(using point: CGPoint) -> CGFloat {
        if touchPosition == .left {
            return previousPoint.x - point.x
        } else {
            return point.x - previousPoint.x
        }
    }
    
    private func leadingInsetForLeftTouchPosition(using delta: CGFloat) -> CGFloat {
        let inset = leadingInset(using: delta)
        
        if delta > 0 {
            let maxX = handlerView.frame.maxX
            return min(inset, maxX - minWidth)
        } else {
            return inset
        }
    }
    
    private func width(using delta: CGFloat) -> CGFloat {
        let width = widthConstraint.constant + delta
        let maxWidth = self.maxWidth(using: delta)
        return min(max(minWidth, width), maxWidth)
    }
    
    private func maxWidth(using delta: CGFloat) -> CGFloat {
        let maxWidth = bounds.width
        
        if leadingConstraint.constant > 0 {
            return maxWidth - leadingConstraint.constant
        } else if touchPosition == .left {
            if delta < 0 {
                return widthConstraint.constant
            } else {
                return handlerView.frame.maxX
            }
        } else {
            return maxWidth
        }
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        endTracking()
    }
    
    public override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        endTracking()
    }
    
    private func endTracking() {
        touchPosition = .outside
        previousPoint = nil
    }
}
