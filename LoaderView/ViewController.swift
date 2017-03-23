//
//  ViewController.swift
//  LoaderView
//
//  Created by Jeremy Fox on 2/17/16.
//  Copyright © 2016 Jeremy Fox. All rights reserved.
//

import UIKit
import LoaderView

class ViewController: UIViewController {

    fileprivate let loaderView = LoaderView()
    
    @IBAction func performLoadingTask(_ sender: AnyObject) {
        loaderView.label.text = "Loading..."
        loaderView.startLoadingInView(view)
        
        var delayTime = DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.loaderView.label.text = "Hang in there..."
        }
        
        delayTime = DispatchTime.now() + Double(Int64(4.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.loaderView.label.text = "Almost done..."
        }
        
        delayTime = DispatchTime.now() + Double(Int64(6.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.loaderView.label.text = "Just a bit more..."
        }
        
        delayTime = DispatchTime.now() + Double(Int64(8.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.loaderView.label.text = "Done!"
            self.loaderView.loadingComplete()
        }
    }

}

