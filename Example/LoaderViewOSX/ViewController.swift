//
//  ViewController.swift
//  LoaderViewOSX
//
//  Created by Jeremy Fox on 2/17/16.
//  Copyright © 2016 Jeremy Fox. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    private let loaderView = LoaderView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loaderView.label.stringValue = "Loading..."
        loaderView.startLoadingInView(view)
        
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.stringValue = "Hang in there..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.stringValue = "Almost done..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(6.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.stringValue = "Just a bit more..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(8.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.stringValue = "Done!"
            self.loaderView.loadingComplete()
        }
    }
    
}

