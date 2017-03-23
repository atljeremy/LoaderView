/**
The MIT License (MIT)

Copyright (c) 2016 Jeremy Fox

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#if os(iOS) || os(watchOS)
    
    import UIKit
    public typealias LVFont             = UIFont
    public typealias LVColor            = UIColor
    public typealias LVViewController   = UIViewController
    public typealias LVView             = UIView
    public typealias LVVisualEffectView = UIVisualEffectView
    public typealias LVVibrancyEffect   = UIVibrancyEffect
    public typealias LVLabel            = UILabel
    public typealias LVBezierPath       = UIBezierPath
    
#elseif os(OSX)
    
    import Cocoa
    public typealias LVFont             = NSFont
    public typealias LVColor            = NSColor
    public typealias LVViewController   = NSViewController
    public typealias LVView             = NSView
    public typealias LVVisualEffectView = NSVisualEffectView
    public typealias LVBlurEffect       = ExpressibleByNilLiteral
    public typealias LVVibrancyEffect   = ExpressibleByNilLiteral
    public typealias LVLabel            = NSTextField
    public typealias LVBezierPath       = NSBezierPath
    
    extension NSBezierPath {
        var CGPath: CGPath? {
            if self.elementCount == 0 {
                return nil
            }
            
            let path = CGMutablePath()
            var didClosePath = false
            
            for i in 0...self.elementCount-1 {
                var points = [NSPoint](repeating
                    : NSZeroPoint, count: 3)
                
                switch self.element(at: i, associatedPoints: &points) {
                case .moveToBezierPathElement: CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .lineToBezierPathElement: CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                case .curveToBezierPathElement: CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                case .closePathBezierPathElement: CGPathCloseSubpath(path)
                didClosePath = true;
                }
            }
            
            if !didClosePath {
                path.closeSubpath()
            }
            
            return path.copy()
        }
    }
    
#endif

public class LoaderView: LVView {
    
    fileprivate var _rotation: CGFloat = 0.0
    fileprivate let _spinnerViewInner = LVView()
    fileprivate let _spinnerViewOuter = LVView()
    fileprivate let _spinnerLayerInner = CAShapeLayer()
    fileprivate let _spinnerLayerOuter = CAShapeLayer()
    fileprivate var _blurView: LVVisualEffectView
    fileprivate var _vibrancyView: LVVisualEffectView
    public fileprivate(set) var animating = false
    public fileprivate(set) var label = LVLabel()
    
    public required init?(coder aDecoder: NSCoder) {
        
        #if os(iOS) || os(watchOS)
            let _blurEffect = UIBlurEffect(style: .dark)
            _blurView = LVVisualEffectView(effect: _blurEffect)
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            let visualEffect = LVVibrancyEffect(blurEffect: _blurEffect)
            _vibrancyView = LVVisualEffectView(effect: visualEffect)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #elseif os(OSX)
            _blurView = LVVisualEffectView()
            _blurView.blendingMode = .WithinWindow
            _blurView.wantsLayer = true
            _blurView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            _blurView.state = .Active
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            _vibrancyView = LVVisualEffectView()
            _vibrancyView.blendingMode = .WithinWindow
            _vibrancyView.wantsLayer = true
            _vibrancyView.state = .Active
            _vibrancyView.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #endif
        
        super.init(coder: aDecoder)
    }
    
    public init() {
        #if os(iOS) || os(watchOS)
            let _blurEffect = UIBlurEffect(style: .dark)
            _blurView = UIVisualEffectView(effect: _blurEffect)
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            let visualEffect = UIVibrancyEffect(blurEffect: _blurEffect)
            _vibrancyView = UIVisualEffectView(effect: visualEffect)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #elseif os(OSX)
            _blurView = LVVisualEffectView()
            _blurView.blendingMode = .withinWindow
            _blurView.wantsLayer = true
            _blurView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            _blurView.state = .active
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            _vibrancyView = LVVisualEffectView()
            _vibrancyView.blendingMode = .withinWindow
            _vibrancyView.wantsLayer = true
            _vibrancyView.state = .active
            _vibrancyView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #endif
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var views: [String: LVView]
        #if os(iOS) || os(watchOS)
            addSubview(_blurView)
            views = ["blurView": _blurView]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[blurView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[blurView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        #endif
        
        addSubview(_vibrancyView)
        views = ["vibrancyView": _vibrancyView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[vibrancyView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[vibrancyView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        /// Configure label and add as subview
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = LVColor.clear
        label.textColor = LVColor.white
        views = ["label": label]
        #if os(iOS) || os(watchOS)
            label.textAlignment = .center
            addSubview(label)
            
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label(==44)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[label(==150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        #elseif os(OSX)
            //TODO: Set text alignement center
            _vibrancyView.addSubview(label)
            label.isEditable = false
            label.isSelectable = false
            label.isBordered = false
            label.isBezeled = false
            label.drawsBackground = false
            
            _vibrancyView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[label(==44)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[label(==150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: _vibrancyView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: _vibrancyView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        #endif

        
        /// Configure _spinnerLayerOuter and add as sublayer to _spinnerView
        _spinnerLayerOuter.path = LVBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 200, height: 200)).cgPath
        _spinnerLayerOuter.lineWidth = 7.0
        _spinnerLayerOuter.strokeStart = 0.0
        _spinnerLayerOuter.strokeEnd = 0.6
        _spinnerLayerOuter.lineCap = kCALineCapRound
        _spinnerLayerOuter.fillColor = LVColor.clear.cgColor
        _spinnerLayerOuter.strokeColor = LVColor.white.cgColor
        #if os(iOS) || os(watchOS)
            _spinnerViewOuter.layer.addSublayer(_spinnerLayerOuter)
        #elseif os(OSX)
            _spinnerViewOuter.wantsLayer = true
            _spinnerViewOuter.layer = _spinnerLayerOuter
        #endif
        
        
        /// Configure _spinnerLayerInner and add as sublayer to _spinnerView
        _spinnerLayerInner.path = LVBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 175, height: 175)).cgPath
        _spinnerLayerInner.lineWidth = 5.0
        _spinnerLayerInner.strokeStart = 0.0
        _spinnerLayerInner.strokeEnd = 0.4
        _spinnerLayerInner.lineCap = kCALineCapRound
        _spinnerLayerInner.fillColor = LVColor.clear.cgColor
        _spinnerLayerInner.strokeColor = LVColor.white.cgColor
        #if os(iOS) || os(watchOS)
            _spinnerViewInner.layer.addSublayer(_spinnerLayerInner)
        #elseif os(OSX)
            _spinnerViewInner.wantsLayer = true
            _spinnerViewInner.layer = _spinnerLayerInner
        #endif
        
        
        /// Confugre _spinnerView and add constraints
        _spinnerViewOuter.translatesAutoresizingMaskIntoConstraints = false
        _spinnerViewInner.translatesAutoresizingMaskIntoConstraints = false
        
        #if os(iOS) || os(watchOS)
            _vibrancyView.contentView.addSubview(_spinnerViewOuter)
            _vibrancyView.contentView.addSubview(_spinnerViewInner)
            views = ["spinnerViewInner": _spinnerViewInner, "spinnerViewOuter": _spinnerViewOuter]
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .centerX, relatedBy: .equal, toItem: _vibrancyView.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .centerY, relatedBy: .equal, toItem: _vibrancyView.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .centerX, relatedBy: .equal, toItem: _vibrancyView.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .centerY, relatedBy: .equal, toItem: _vibrancyView.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        #elseif os(OSX)
            _vibrancyView.addSubview(_spinnerViewOuter)
            _vibrancyView.addSubview(_spinnerViewInner)
            views = ["spinnerViewInner": _spinnerViewInner, "spinnerViewOuter": _spinnerViewOuter]
            _vibrancyView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .CenterX, relatedBy: .Equal, toItem: _vibrancyView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .CenterY, relatedBy: .Equal, toItem: _vibrancyView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            
            _vibrancyView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .CenterX, relatedBy: .Equal, toItem: _vibrancyView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .CenterY, relatedBy: .Equal, toItem: _vibrancyView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        #endif
        
        #if os(OSX)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowResized", name: NSWindowDidResizeNotification, object: nil)
        #endif
    }
    
#if os(iOS) || os(watchOS)
    override public func didMoveToSuperview() {
        let views = ["loaderView": self]
        superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        superview?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        super.didMoveToSuperview()
    }
#elseif os(OSX)
    override public func viewDidMoveToSuperview() {
        let views = ["loaderView": self]
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        super.viewDidMoveToSuperview()
    }
    
    func setAnchorPoint(anchorPoint: NSPoint, view: NSView) {
        guard let layer = view.layer else { return }
        
        let oldOrigin = layer.frame.origin
        layer.anchorPoint = anchorPoint
        let newOrigin = layer.frame.origin
        
        let transition = NSMakePoint(newOrigin.x - oldOrigin.x, newOrigin.y - oldOrigin.y)
        layer.frame.origin = NSMakePoint(layer.frame.origin.x - transition.x, layer.frame.origin.y - transition.y)
    }
    
    func windowResized() {
        self.setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewInner)
        self.setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewOuter)
    }
#endif
    
    public func startLoadingInView(_ view: LVView) {
        _spinnerLayerInner.strokeStart = 0.0
        _spinnerLayerInner.strokeEnd   = 0.4
        _spinnerLayerOuter.strokeStart = 0.0
        _spinnerLayerOuter.strokeEnd   = 0.6
        
        #if os(iOS) || os(watchOS)
            transform = CGAffineTransform.identity
            alpha = 0
        #elseif os(OSX)
            self.animator().alphaValue = 0
            _blurView.animator().alphaValue = 0
            _vibrancyView.animator().alphaValue = 0
            _spinnerViewInner.animator().alphaValue = 0
            _spinnerViewOuter.animator().alphaValue = 0
        #endif
        
        view.addSubview(self)
        
        DispatchQueue.main.async {
            
            #if os(OSX)
                self.setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewInner)
                self.setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewOuter)
            #endif
            
            self.startAnimating()
            #if os(iOS) || os(watchOS)
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 1
                }) 
            #elseif os(OSX)
                /// This displatch_after is basically a hack to hide the woncky movement of the lines before they start to spin, not exactly sure why this is happening
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 1
                        self._spinnerViewInner.animator().alphaValue = 1
                        self._spinnerViewOuter.animator().alphaValue = 1
                    }, completionHandler: nil)
                }
                
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 1
                    self.animator().alphaValue = 1
                    self._blurView.animator().alphaValue = 1
                    self._vibrancyView.animator().alphaValue = 1
                }, completionHandler: nil)
            #endif
        }
    }
    
    public func loadingComplete() {
        animating = false
    }
    
    fileprivate func startAnimating() {
        animating = true
        runAnimations()
    }
    
    fileprivate func runAnimations() {
        #if os(iOS) || os(watchOS)
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
                self._rotation += CGFloat(M_PI_4)
                self._spinnerViewOuter.transform = CGAffineTransform(rotationAngle: self._rotation)
                self._spinnerViewInner.transform = CGAffineTransform(rotationAngle: -self._rotation)
            }) { finished in
                if finished {
                    if self.animating {
                        self.runAnimations()
                    } else {
                        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: UIViewKeyframeAnimationOptions(), animations: {
                            
                            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2) {
                                self._spinnerLayerInner.strokeStart = 0.0
                                self._spinnerLayerInner.strokeEnd   = 1.0
                                self._spinnerLayerOuter.strokeStart = 0.0
                                self._spinnerLayerOuter.strokeEnd   = 1.0
                            }
                            
                            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                                self.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
                                self.alpha = 0.0
                            }
                            
                        }) { finished in
                            self.removeFromSuperview()
                        }
                    }
                }
            }
        #elseif os(OSX)
            NSAnimationContext.runAnimationGroup({ context in
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                context.duration = 0.2
                self._rotation += CGFloat(M_PI_4)
                self._spinnerViewOuter.layer?.setAffineTransform(CGAffineTransformMakeRotation(self._rotation))
                self._spinnerViewInner.layer?.setAffineTransform(CGAffineTransformMakeRotation(-self._rotation))
            }) {
                if self.animating {
                    self.runAnimations()
                } else {
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.5
                        self._spinnerLayerInner.strokeStart = 0.0
                        self._spinnerLayerInner.strokeEnd   = 1.0
                        self._spinnerLayerOuter.strokeStart = 0.0
                        self._spinnerLayerOuter.strokeEnd   = 1.0
                        
                    }) {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.duration = 1
                            self.animator().alphaValue = 0
                            self._blurView.animator().alphaValue = 0
                            self._vibrancyView.animator().alphaValue = 0
                        }) {
                            self.removeFromSuperview()
                        }
                    }
                }
            }
        #endif
    }
}
