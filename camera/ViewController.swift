//
//  ViewController.swift
//  camera
//
//  Created by suihong on 16/3/19.
//  Copyright © 2016年 suihong. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    let cameraViewController = CameraViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    @IBAction func btnClicked(sender: AnyObject) {
        self.presentViewController(cameraViewController, animated: true, completion: { () -> Void in
            print("preseneted")
            
            
        })
    }

}

