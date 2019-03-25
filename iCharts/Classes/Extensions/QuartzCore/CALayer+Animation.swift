//
//  CALayer+Animation.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/22/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

// MARK: - Animation

extension CALayer {
    
    struct Animation {
        let duration: CFTimeInterval?
        let value: Any?
        let defaultValue: Any?
        let key: String
        let isBaked: Bool
        let isFromPresentation: Bool
        let shouldSkipNil: Bool

        public init(duration: CFTimeInterval?,
                    value: Any?,
                    defaultValue: Any? = nil,
                    key: String,
                    isBaked: Bool = true,
                    isFromPresentation: Bool = true,
                    shouldSkipNil: Bool = false) {
            
            self.duration = duration
            self.value = value
            self.defaultValue = defaultValue
            self.key = key
            self.isBaked = isBaked
            self.isFromPresentation = isFromPresentation
            self.shouldSkipNil = shouldSkipNil
        }
    }
}


// MARK: - Default Animations

extension CALayer.Animation {
    
    static func fillColor(_ fillColor: CGColor, duration: CFTimeInterval? = nil) -> CALayer.Animation {
        return CALayer.Animation(duration: duration, value: fillColor, key: "fillColor")
    }
    
    static func strokeColor(_ strokeColor: CGColor, duration: CFTimeInterval? = nil) -> CALayer.Animation {
        return CALayer.Animation(duration: duration, value: strokeColor, key: "strokeColor")
    }
    
    static func lineWidth(_ lineWidth: CGFloat, duration: CFTimeInterval? = nil) -> CALayer.Animation {
        return CALayer.Animation(duration: duration, value: lineWidth, defaultValue: 1, key: "lineWidth")
    }
    
    static func path(_ path: CGPath?, duration: CFTimeInterval? = nil) -> CALayer.Animation {
        return CALayer.Animation(duration: duration, value: path, key: "path", shouldSkipNil: true)
    }
}


// MARK: - Animate

extension CALayer {
    
    func animate(duration: CFTimeInterval? = nil, group animations: [Animation]) {
        let group = animationGroup(with: animations)
        if let duration = duration {
            group.duration = duration
        }
        add(group, forKey: animations.animationKey)
    }
    
    private func animationGroup(with animations: [Animation]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        group.animations = animations.compactMap(basicAnimation(using:))
        return group
    }
    
    private func basicAnimation(using animation: Animation) -> CABasicAnimation? {
        let key = animation.key
        let basicAnimation = CABasicAnimation(keyPath: key)
        
        if animation.isFromPresentation {
            self[key] = presentation()?[key] ?? animation.defaultValue
        }
        
        let value = animation.value
        guard !(value == nil && animation.shouldSkipNil) else {
            return nil
        }
        
        if let duration = animation.duration {
            basicAnimation.duration = duration
        }
        
        basicAnimation.fromValue = self[key]
        basicAnimation.toValue = value
        
        if animation.isBaked {
            self[key] = value
        }
        
        return basicAnimation
    }
}


// MARK: - Subscript

extension CALayer {
    
    subscript(key: String) -> Any? {
        get { return value(forKey: key) }
        set { setValue(newValue, forKey: key) }
    }
}


// MARK: - Animation Key

extension Array where Element == CALayer.Animation {
    
    var animationKey: String {
        return values(keyPath: \.key)
            .sorted()
            .joined(separator: ", ")
    }
}
