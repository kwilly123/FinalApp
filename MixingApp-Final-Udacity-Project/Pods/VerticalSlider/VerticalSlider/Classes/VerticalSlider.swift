//
//  VerticalSlider.swift
//  AionLED
//
//  Created by Jon Kent on 7/12/16.
//  Copyright © 2016 AionLED. All rights reserved.
//

import UIKit

open class VerticalSlider: UIControl {
    
    public let slider = UISlider()
    
    // required for IBDesignable class to properly render
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    // required for IBDesignable class to properly render
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    fileprivate func initialize() {
        updateSlider()
        slider.setThumbImage(UIImage(named: "volume-fader"), for: .normal)
        addSubview(slider)
    }
    
    fileprivate func updateSlider() {
        if ascending {
            slider.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5).scaledBy(x: 1, y: -1)
        } else {
            slider.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
        }
    }
    
    open var ascending: Bool = false {
        didSet {
            updateSlider()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // HACK:
        // Rotate the thumb image for the downward drop shadow. As of iOS 11, the thumb is a premade image.
        // If you don't want a drop shadow, replace the slider's currentThumbImage.
        if let thumb = slider.subviews.last as? UIImageView {
            if ascending {
                thumb.transform = CGAffineTransform(rotationAngle: CGFloat.pi * -0.5)
            } else {
                thumb.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
            }
        }
        
        slider.bounds.size.width = bounds.height
        slider.center.x = bounds.midX
        slider.center.y = bounds.midY
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: slider.intrinsicContentSize.height, height: slider.intrinsicContentSize.width)
        }
    }
    
    open var minimumValue: Float {
        get {
            return slider.minimumValue
        }
        set {
            slider.minimumValue = newValue
        }
    }
    
    open var maximumValue: Float {
        get {
            return slider.maximumValue
        }
        set {
            slider.maximumValue = newValue
        }
    }
    
    open var value: Float {
        get {
            return slider.value
        }
        set {
            slider.setValue(newValue, animated: true)
        }
    }
    
    open var thumbTintColor: UIColor? {
        get {
            return slider.thumbTintColor
        }
        set {
            slider.thumbTintColor = newValue
        }
    }
    
    open var minimumTrackTintColor: UIColor? {
        get {
            return slider.minimumTrackTintColor
        }
        set {
            slider.minimumTrackTintColor = newValue
        }
    }
    
    open var maximumTrackTintColor: UIColor? {
        get {
            return slider.maximumTrackTintColor
        }
        set {
            slider.maximumTrackTintColor = newValue
        }
    }
    
    open var isContinuous: Bool {
        get {
            return slider.isContinuous
        }
        set {
            slider.isContinuous = newValue
        }
    }
    
    open override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        slider.addTarget(target, action: action, for: controlEvents)
    }
    
    open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {
        slider.removeTarget(target, action: action, for: controlEvents)
    }
    
}
