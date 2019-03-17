//
//  ExpandableSliderView.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/14/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

private let minWidth: CGFloat = 100

public final class ExpandableSliderView: UIControl {
    
    public var sliderState: SliderState {
        return SliderState(position: position, startBound: startBound, endBound: endBound, visiblePart: visiblePart)
    }
    
    public var visiblePart: CGFloat {
        get { return _visiblePart }
        set {} // TODO: adjust frame
    }
    private lazy var _visiblePart: CGFloat = {
       return handlerWidth / bounds.width
    }()
    
    public var position: CGFloat {
        get { return _position }
        set {} // TODO: adjust frame
    }
    private var _position: CGFloat = 0
    
    public var startBound: CGFloat {
        return leadingInset / bounds.width
    }
    
    public var endBound: CGFloat {
        return (leadingInset + handlerWidth) / bounds.width
    }
    
    private var widthConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    
    private var handlerWidth: CGFloat {
        get { return widthConstraint.constant }
        set {
            widthConstraint.constant = newValue
            set(value: newValue / bounds.width, keyPath: \ExpandableSliderView._visiblePart)
        }
    }
    
    private var leadingInset: CGFloat {
        get { return leadingConstraint.constant }
        set {
            leadingConstraint.constant = newValue

            let deltaWidth = bounds.width - handlerWidth
            let value = deltaWidth == 0 ? 0 : newValue / deltaWidth

            set(value: value, keyPath: \ExpandableSliderView._position)
        }
    }
    
    private func set<T>(value: T,
                        keyPath: ReferenceWritableKeyPath<ExpandableSliderView, T>,
                        shouldNotify: Bool = true) {
        
        self[keyPath: keyPath] = value
        if shouldNotify {
            sendActions(for: .valueChanged)
        }
    }
    
    
    // MARK: - Sublayers
    
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
        
        view.backgroundColor = UIColor(hexString: "#E0FFFF", alpha: 0.2)
        view.clipsToBounds = true
        
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
    
    
    // MARK: - UIView
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.layer.mask = makeOverlayMask()
    }
    
    private func makeOverlayMask() -> CALayer {
        let path = UIBezierPath(rect: bounds)
        path.append(UIBezierPath(rect: handlerView.innerFrame))
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillRule = .evenOdd
        
        return layer
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
        leadingInset = leadingInset(using: delta)
    }
    
    private func leadingInset(using delta: CGFloat) -> CGFloat {
        let leadingInset = self.leadingInset + delta
        let minBound: CGFloat = 0
        let maxBound = bounds.width - handlerWidth
        return min(max(minBound, leadingInset), maxBound)
    }
    
    private func changeHandlerWidth(using point: CGPoint) {
        let isRightDirection = (point.x - previousPoint.x) > 0
        
        if touchPosition == .left, isRightDirection, handlerWidth == minWidth {
            return
        }
        
        let delta = self.delta(using: point)
        
        if touchPosition == .left {
            leadingInset = leadingInsetForLeftTouchPosition(using: -delta)
        }
        
        handlerWidth = self.width(using: delta)
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
        let width = handlerWidth + delta
        let maxWidth = self.maxWidth(using: delta)
        return min(max(minWidth, width), maxWidth)
    }
    
    private func maxWidth(using delta: CGFloat) -> CGFloat {
        let maxWidth = bounds.width
        
        if leadingInset > 0 {
            return maxWidth - leadingInset
        } else if touchPosition == .left {
            if delta < 0 {
                return handlerWidth
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


extension ExpandableSliderView {
    
    public struct SliderState {
        public let position: CGFloat
        public let startBound: CGFloat
        public let endBound: CGFloat
        public let visiblePart: CGFloat
        
        init(position: CGFloat, startBound: CGFloat, endBound: CGFloat, visiblePart: CGFloat) {
            self.position = position
            self.startBound = startBound
            self.endBound = endBound
            self.visiblePart = visiblePart
        }
    }
}
