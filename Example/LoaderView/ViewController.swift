//
//  ViewController.swift
//  LoaderView
//
//  Created by Jeremy Fox on 2/17/16.
//  Copyright © 2016 Jeremy Fox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let loaderView = LoaderView()
    
    @IBAction func performLoadingTask(sender: AnyObject) {
        loaderView.label.text = "Loading..."
        loaderView.startLoadingInView(view)
        
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.text = "Hang in there..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.text = "Almost done..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(6.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.text = "Just a bit more..."
        }
        
        delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(8.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.loaderView.label.text = "Done!"
            self.loaderView.loadingComplete()
        }
    }

}

