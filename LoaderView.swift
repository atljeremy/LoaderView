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
    public typealias LVBlurEffect       = NilLiteralConvertible
    public typealias LVVibrancyEffect   = NilLiteralConvertible
    public typealias LVLabel            = NSTextField
    public typealias LVBezierPath       = NSBezierPath
    
    extension NSBezierPath {
        var CGPath: CGPathRef? {
            if self.elementCount == 0 {
                return nil
            }
            
            let path = CGPathCreateMutable()
            var didClosePath = false
            
            for i in 0...self.elementCount-1 {
                var points = [NSPoint](count: 3, repeatedValue: NSZeroPoint)
                
                switch self.elementAtIndex(i, associatedPoints: &points) {
                case .MoveToBezierPathElement: CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement: CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                case .CurveToBezierPathElement: CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                case .ClosePathBezierPathElement: CGPathCloseSubpath(path)
                didClosePath = true;
                }
            }
            
            if !didClosePath {
                CGPathCloseSubpath(path)
            }
            
            return CGPathCreateCopy(path)
        }
    }
    
    func setAnchorPoint(anchorPoint: NSPoint, view: NSView) {
        guard let layer = view.layer else { return }
        
        let oldOrigin = layer.frame.origin
        layer.anchorPoint = anchorPoint
        let newOrigin = layer.frame.origin
        
        let transition = NSMakePoint(newOrigin.x - oldOrigin.x, newOrigin.y - oldOrigin.y)
        layer.frame.origin = NSMakePoint(layer.frame.origin.x - transition.x, layer.frame.origin.y - transition.y)
    }
    
#endif

class LoaderView: LVView {
    
    private var _rotation: CGFloat = 0.0
    private let _spinnerViewInner = LVView()
    private let _spinnerViewOuter = LVView()
    private let _spinnerLayerInner = CAShapeLayer()
    private let _spinnerLayerOuter = CAShapeLayer()
    private var _blurView: LVVisualEffectView
    private var _vibrancyView: LVVisualEffectView
    private(set) var animating = false
    private(set) var label = LVLabel()
    
    required init?(coder aDecoder: NSCoder) {
        
        #if os(iOS) || os(watchOS)
            let _blurEffect = UIBlurEffect(style: .Dark)
            _blurView = LVVisualEffectView(effect: _blurEffect)
            let visualEffect = LVVibrancyEffect(forBlurEffect: _blurEffect)
            _vibrancyView = LVVisualEffectView(effect: visualEffect)
        #elseif os(OSX)
            _blurView = LVVisualEffectView()
            _blurView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
            _blurView.material = NSVisualEffectMaterial.Dark
            _blurView.state = NSVisualEffectState.Active
            
            _vibrancyView = LVVisualEffectView()
            _vibrancyView.blendingMode = .BehindWindow
            _vibrancyView.material = .Dark
            _vibrancyView.state = .Active
        #endif
        
        super.init(coder: aDecoder)
    }
    
    init() {
        #if os(iOS) || os(watchOS)
            let _blurEffect = UIBlurEffect(style: .Dark)
            _blurView = UIVisualEffectView(effect: _blurEffect)
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            let visualEffect = UIVibrancyEffect(forBlurEffect: _blurEffect)
            _vibrancyView = UIVisualEffectView(effect: visualEffect)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #elseif os(OSX)
            _blurView = LVVisualEffectView()
            _blurView.blendingMode = .WithinWindow
            _blurView.wantsLayer = true
//            _blurView.material = .Dark
            _blurView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            _blurView.state = .Active
            _blurView.translatesAutoresizingMaskIntoConstraints = false
            
            _vibrancyView = LVVisualEffectView()
            _vibrancyView.blendingMode = .WithinWindow
            _vibrancyView.wantsLayer = true
            _vibrancyView.state = .Active
            _vibrancyView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            _vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        #endif
        
        super.init(frame: CGRectZero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var views: [String: LVView]
        #if os(iOS) || os(watchOS)
            addSubview(_blurView)
            views = ["blurView": _blurView]
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[blurView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[blurView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        #endif
        
        addSubview(_vibrancyView)
        views = ["vibrancyView": _vibrancyView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[vibrancyView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[vibrancyView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        /// Configure label and add as subview of self
        label.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS) || os(watchOS)
            label.textAlignment = .Center
            addSubview(label)
        #elseif os(OSX)
            //TODO: Set text alignement center
            addSubview(label, positioned: .Above, relativeTo: _vibrancyView)
        #endif
        label.backgroundColor = LVColor.clearColor()
        label.textColor = LVColor.whiteColor()
        views = ["label": label]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label(==150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[label(==150)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        /// Configure _spinnerLayerOuter and add as sublayer to _spinnerView
        _spinnerLayerOuter.path = LVBezierPath(ovalInRect: CGRectMake(0, 0, 200, 200)).CGPath
        _spinnerLayerOuter.lineWidth = 7.0
        _spinnerLayerOuter.strokeStart = 0.0
        _spinnerLayerOuter.strokeEnd = 0.6
        _spinnerLayerOuter.lineCap = kCALineCapRound
        _spinnerLayerOuter.fillColor = LVColor.clearColor().CGColor
        _spinnerLayerOuter.strokeColor = LVColor.whiteColor().CGColor
        #if os(iOS) || os(watchOS)
            _spinnerViewOuter.layer.addSublayer(_spinnerLayerOuter)
        #elseif os(OSX)
            _spinnerViewOuter.wantsLayer = true
            _spinnerViewOuter.layer = _spinnerLayerOuter
            
        #endif
        
        
        /// Configure _spinnerLayerInner and add as sublayer to _spinnerView
        _spinnerLayerInner.path = LVBezierPath(ovalInRect: CGRectMake(0, 0, 175, 175)).CGPath
        _spinnerLayerInner.lineWidth = 5.0
        _spinnerLayerInner.strokeStart = 0.0
        _spinnerLayerInner.strokeEnd = 0.4
        _spinnerLayerInner.lineCap = kCALineCapRound
        _spinnerLayerInner.fillColor = LVColor.clearColor().CGColor
        _spinnerLayerInner.strokeColor = LVColor.whiteColor().CGColor
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
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[spinnerViewOuter(==200)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .CenterX, relatedBy: .Equal, toItem: _vibrancyView.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewInner, attribute: .CenterY, relatedBy: .Equal, toItem: _vibrancyView.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[spinnerViewInner(==175)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .CenterX, relatedBy: .Equal, toItem: _vibrancyView.contentView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            _vibrancyView.contentView.addConstraint(NSLayoutConstraint(item: _spinnerViewOuter, attribute: .CenterY, relatedBy: .Equal, toItem: _vibrancyView.contentView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
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
    }
    
#if os(iOS) || os(watchOS)
    override func didMoveToSuperview() {
        let views = ["loaderView": self]
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        super.didMoveToSuperview()
    }
#elseif os(OSX)
    override func viewDidMoveToSuperview() {
        let views = ["loaderView": self]
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        superview?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[loaderView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        super.viewDidMoveToSuperview()
    }
#endif
    
    func startLoadingInView(view: LVView) {
        _spinnerLayerInner.strokeStart = 0.0
        _spinnerLayerInner.strokeEnd   = 0.4
        _spinnerLayerOuter.strokeStart = 0.0
        _spinnerLayerOuter.strokeEnd   = 0.6
        
        #if os(iOS) || os(watchOS)
            transform = CGAffineTransformIdentity
            alpha = 0
        #elseif os(OSX)
            self.animator().alphaValue = 0
            _blurView.animator().alphaValue = 0
            _vibrancyView.animator().alphaValue = 0
        #endif
        
        view.addSubview(self)
        
        dispatch_async(dispatch_get_main_queue()) {
            
            setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewInner)
            setAnchorPoint(CGPointMake(0.5, 0.5), view: self._spinnerViewOuter)
            
            self.startAnimating()
            #if os(iOS) || os(watchOS)
                UIView.animateWithDuration(0.3) {
                    self.alpha = 1
                }
            #elseif os(OSX)
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 1
                    self.animator().alphaValue = 1
                    self._blurView.animator().alphaValue = 1
                    self._vibrancyView.animator().alphaValue = 1
                    self._spinnerViewInner.animator().alphaValue = 1
                    self._spinnerViewOuter.animator().alphaValue = 1
                }, completionHandler: nil)
            #endif
        }
    }
    
    func loadingComplete() {
        animating = false
    }
    
    private func startAnimating() {
        animating = true
        runAnimations()
    }
    
    private func runAnimations() {
        #if os(iOS) || os(watchOS)
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
                self._rotation += CGFloat(M_PI_4)
                self._spinnerViewOuter.transform = CGAffineTransformMakeRotation(self._rotation)
                self._spinnerViewInner.transform = CGAffineTransformMakeRotation(-self._rotation)
            }) { finished in
                if finished {
                    if self.animating {
                        self.runAnimations()
                    } else {
                        UIView.animateKeyframesWithDuration(1.0, delay: 0.0, options: .CalculationModeLinear, animations: {
                            
                            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/2) {
                                self._spinnerLayerInner.strokeStart = 0.0
                                self._spinnerLayerInner.strokeEnd   = 1.0
                                self._spinnerLayerOuter.strokeStart = 0.0
                                self._spinnerLayerOuter.strokeEnd   = 1.0
                            }
                            
                            UIView.addKeyframeWithRelativeStartTime(1/2, relativeDuration: 1/2) {
                                self.transform = CGAffineTransformMakeScale(5.0, 5.0)
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
