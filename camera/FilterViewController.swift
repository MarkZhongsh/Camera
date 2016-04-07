//
//  FilterViewController.swift
//  camera
//
//  Created by suihong on 16/3/21.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class FilterViewController : UIViewController{
    
    var orignalImg: UIImage!
    var imageView: UIImageView!
    
    var topView: UIView!
    //var cancelBtn: UIButton!
    //var saveBtn: UIButton!
    
    var bottomView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView.init(image: orignalImg)
        self.view.addSubview(imageView)
        imageView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.height.equalTo(self.view)
        })
        let gesture = UITapGestureRecognizer(target: self, action: Selector("imageViewTouch:"))
        imageView.addGestureRecognizer(gesture)
        imageView.userInteractionEnabled = true
        
        //创建顶部工具栏
        topView = UIView()
        topView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(topView)
        topView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.equalTo(topView.superview!)
            make.height.equalTo(100)
        })
        
        let cancelBtn = UIButton.init(type: .System)
        cancelBtn.setTitle("cancel", forState: .Normal)
        topView.addSubview(cancelBtn)
        cancelBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(10)
            make.centerY.equalTo(cancelBtn.superview!)
        })
        cancelBtn.addTarget(self, action: "cancelBtnClicked", forControlEvents: .TouchUpInside)
        
        let saveBtn = UIButton.init(type: .System)
        saveBtn.setTitle("save", forState: .Normal)
        topView.addSubview(saveBtn)
        saveBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(saveBtn.superview!)
            make.right.equalTo(-10)
        })
        saveBtn.addTarget(self, action: "saveBtnClicked", forControlEvents: .TouchUpInside)
        
        //设备底部工具栏
        bottomView = UIView()
        bottomView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(bottomView)
        bottomView.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(0)
            make.width.equalTo(bottomView.superview!)
            make.height.equalTo(100)
        })
        
        let filterBtn = UIButton.init(type: .System)
        filterBtn.setTitle("filter", forState: .Normal)
        filterBtn.addTarget(self, action: "filterBtnClicked", forControlEvents: .TouchUpInside)
        bottomView.addSubview(filterBtn)
        filterBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(10)
            make.centerY.equalTo(filterBtn.superview!)
        })
    }
    
    func createFiltersTable() -> Void {
        
    }
    
    //MARK: - 控件业务
    func cancelBtnClicked() -> Void {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveBtnClicked() -> Void {
        ImageUtil.ImageSave(image: self.imageView.image!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func filterBtnClicked() -> Void {
        print(__FUNCTION__)
        let ciImg = Filter.filterImage(filterName: "CIPhotoEffectNoir", image: CIImage(image: orignalImg)!)
        
        self.imageView.image = UIImage.init(CIImage: ciImg!)
//        self.imageView.image?.imageOrientation
    }
    
    func imageViewTouch(sender: UITapGestureRecognizer) -> Void {
        print(__FUNCTION__)
        
        self.bottomView.hidden = !self.bottomView.hidden
        self.topView.hidden = !self.topView.hidden
    }
    
    
    
}