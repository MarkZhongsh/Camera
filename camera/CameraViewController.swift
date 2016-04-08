//
//  CameraViewController.swift
//  camera
//
//  Created by suihong on 16/3/19.
//  Copyright © 2016年 suihong. All rights reserved.
//


import SnapKit
import UIKit
import AVFoundation
import AssetsLibrary

class CameraViewController: UIViewController, CameraDelegate,UICollectionViewDataSource,UICollectionViewDelegate{
    var mainView = UIView()
    //var imageView = UIImageView()
    
    var topView = UIView()
    lazy var changeBtn = UIButton()
    
    var bottomView = UIView()
    var captureBtn = UIButton()
    var filterBtn = UIButton()
    
    var filterContainter: UIView!
    var filterColView : UICollectionView!
    var currentFilterName = ""
    
    var previewLayer: CALayer!
    var camera: Camera!
    var context: CIContext!
    var faceViews: [UIView]!
    
    let filters = ["none","CIPhotoEffectNoir","CIPhotoEffectTonal","CIPhotoEffectTransfer","CIPhotoEffectMono","CIPhotoEffectFade","CIPhotoEffectProcess","CIPhotoEffectChrome"]
    
    var times = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.backgroundColor = UIColor.whiteColor()
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mainView)
        
        mainView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.height.equalTo(self.view)

        })
        
        addTopView()
        addBottomView()
        addFilterCollection()
        
        faceViews = []
        
        camera = Camera()
        camera.delegate = self
        camera.startCapture()
    }
    
    //MARK: - 界面初始化
    private func addTopView() {
        //顶部栏初始化 -- begin
        mainView.addSubview(topView)
        topView.backgroundColor = UIColor.whiteColor()
        topView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.equalTo(topView.superview!)
            make.height.equalTo(50)
            
        })
        
        topView.addSubview(changeBtn)
        changeBtn.setTitle("change", forState: .Normal)
        changeBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        changeBtn.snp_makeConstraints(closure: { (make) -> Void in
            //make.top.equalTo(10)
            make.centerY.equalTo(changeBtn.superview!)
            make.right.equalTo(-5)
        })
        changeBtn.addTarget(self, action: #selector(changeBtnClicked), forControlEvents: .TouchUpInside)
        //顶部栏初始化 -- end
    }
    
    private func addBottomView() {
        //底部栏初始化 -- begin
        mainView.addSubview(bottomView)
        bottomView.backgroundColor = UIColor.whiteColor()
        bottomView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.equalTo(bottomView.superview!)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        })
        
        bottomView.addSubview(captureBtn)
        captureBtn.setTitle("capture", forState: .Normal)
        captureBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        captureBtn.snp_makeConstraints(closure:{ (make) -> Void in
            make.centerX.equalTo(captureBtn.superview!)
            make.centerY.equalTo(captureBtn.superview!)
            //make.bottom.equalTo(-5)
        })
        captureBtn.addTarget(self, action: #selector(captureBtnClicked), forControlEvents: .TouchUpInside)
        
        bottomView.addSubview(filterBtn)
        filterBtn.setTitle("filters", forState: .Normal)
        filterBtn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        filterBtn.addTarget(self, action: #selector(showFilterContainter), forControlEvents: .TouchUpInside)
        filterBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(filterBtn.superview!)
            make.left.equalTo(5)
        })
        //底部栏初始化 -- end
    }
    
    private func addFilterCollection() -> Void {
        filterContainter = UIView()
        mainView.addSubview(filterContainter)
        //filterContainter.backgroundColor = UIColor.whiteColor()
        //mainView.insertSubview(filterContainter, belowSubview: topView)
        //filterContainter.backgroundColor = UIColor.blueColor()
        filterContainter.translatesAutoresizingMaskIntoConstraints = false
        filterContainter.snp_makeConstraints(closure: { (make) -> Void in
            make.height.width.equalTo(filterContainter.superview!)
//            make.bottom.equalTo(0)
            make.bottom.equalTo(UIScreen.mainScreen().bounds.height)
        })
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 1, 0)
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.itemSize = CGSizeMake(200, 40)
        //filterColView = UICollectionView(frame: CGRectMake(0, 0, 2000, 50), collectionViewLayout: flowLayout)
//        filterColView = UICollectionView()
        filterColView = UICollectionView(frame: CGRectMake(0, 0, 0, 0), collectionViewLayout: flowLayout)
        //filterColView.setCollectionViewLayout(flowLayout, animated: true)
        filterColView.backgroundColor = UIColor.whiteColor()
        filterColView.registerClass(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "filters")
        filterColView.dataSource = self
        filterColView.delegate = self
        filterContainter.addSubview(filterColView)
        filterColView.snp_makeConstraints(closure: { (make) -> Void in
            make.width.equalTo(filterColView.superview!)
            //make.width.equalTo(filterContainter)
            make.right.equalTo(0)
            make.height.equalTo(50)
            make.bottom.equalTo(0)
        })
        
        let hideBtn = UIButton(type: .System)
        hideBtn.setTitle("hide", forState: .Normal)
        hideBtn.addTarget(self, action: #selector(hideFilterContainter), forControlEvents: .TouchUpInside)
        filterContainter.addSubview(hideBtn)
        hideBtn.snp_makeConstraints(closure: { (make) -> Void in
            //make.top.equalTo(self.filterColView)
            //make.top.equalTo(self.filterColView.snp_bottom)
            make.bottom.equalTo(self.filterColView.snp_top)
        })
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filters", forIndexPath: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let btn = UIButton(type: .System)
        btn.setTitle(filters[indexPath.row], forState: .Normal)
        //btn.setTitleColor(UIColor.blueColor(), forState: .Normal)
        btn.bounds = cell.contentView.bounds
        btn.addTarget(self, action: #selector(filterBtnClicked), forControlEvents: .TouchUpInside)
        cell.contentView.addSubview(btn)
        btn.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.centerY.equalTo(btn.superview!)
        })
        return cell
    }
    
    //MARK: - viewcontroller生命周期
    override func viewDidAppear(animated: Bool) {
        camera.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        if previewLayer == nil {
            let layer = mainView.layer
            previewLayer = CALayer()
            //previewLayer.backgroundColor = UIColor.blueColor().CGColor
            //previewLayer.bounds = layer.bounds
            let bounds = CGRectMake(layer.bounds.origin.y, layer.bounds.origin.x, layer.bounds.height, layer.bounds.width)
            previewLayer.bounds = bounds
            previewLayer.position = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds))
            previewLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0)))
            layer.insertSublayer(previewLayer, atIndex: 0)
            
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    //MARK: - 按钮业务
    func changeBtnClicked() -> Void {
        print(#function)
        
        let queue = dispatch_queue_create("shutterCamera", nil)
        dispatch_async(queue, { () -> Void in
          self.camera.shutterCamera()
        })
        
        let scaleAnimation  = CABasicAnimation.init(keyPath: "transform.rotation.x")
        scaleAnimation.fromValue = M_PI * Double(times)
        scaleAnimation.toValue = M_PI * Double(times+1)
        scaleAnimation.duration = 0.5
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.removedOnCompletion = false
        
        previewLayer.addAnimation(scaleAnimation, forKey: nil)
        
        times+=1
        //previewLayer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0)
        //previewLayer.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(M_PI / 2.0)))
    }
    
    func captureBtnClicked() -> Void {
        print(#function)
        camera.stopCapture()
        let cgImg = previewLayer.contents as! CGImage
        var ciImg = CIImage(CGImage: cgImg)
        ciImg = ciImg.imageByApplyingOrientation(6)
        
        let uiImg = UIImage(CIImage: ciImg)
        let filterVC = FilterViewController()
        filterVC.orignalImg = uiImg
        self.presentViewController(filterVC, animated: true, completion: nil)
        //ImageUtil.ImageSave(image: uiImg)
        self.camera.startCapture()
        
    }
    
    func filterBtnClicked(sender: AnyObject) -> Void {
        print(#function)
        let filterBtn = sender as! UIButton
        
        currentFilterName = (filterBtn.titleLabel?.text)!
    }
    
    //展现滤镜列表
    func showFilterContainter() -> Void {
        print(#function)
        //UIView.animateWithDuration(<#T##duration: NSTimeInterval##NSTimeInterval#>, animations: <#T##() -> Void#>)
        
//        let animation = CABasicAnimation(keyPath: "translation.y")
//        animation.fromValue = filterContainter.bounds.height
//        animation.toValue = 0
//        animation.autoreverses = false
//        animation.fillMode = kCAFillModeForwards
//        animation.duration = 1.0
//        filterContainter.layer.addAnimation(animation, forKey: nil)
//        filterContainter.snp_remakeConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(0)
//        })
//        filterContainter.updateConstraints()
//        filterContainter.updateConstraintsIfNeeded()
//        UIView.setAnimationDuration(1)
        var height = filterContainter.bounds.height
        //filterContainter.snp_bottom = 0
        //filterContainter.snp_makeConstraints(closure: <#T##(make: ConstraintMaker) -> Void#>)
//        filterContainter.snp_makeConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(filterContainter.superview!)
//        })
        UIView.animateWithDuration(20.0, animations: { () -> Void in
            self.filterContainter.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(0)
                //make.bottom.equalTo(self.filterContainter.superview!)
                //make.width.height.equalTo(self.filterContainter.superview!)
            })
        })
//        self.filterContainter.snp_remakeConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(self.filterColView.superview!.bounds.height)
//        })
    }
    
    //隐藏滤镜列表
    func hideFilterContainter() -> Void {
        filterContainter.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(UIScreen.mainScreen().bounds.size.height)
        })
    }
    
    //MARK: - Camera代理
    func dealWithImage(image image: CIImage) {
        var cgImage: CGImage? = nil
        var filterImg: CIImage! = image
        if !self.currentFilterName.isEmpty && self.currentFilterName != "none" {
            filterImg = Filter.filterImage(filterName: self.currentFilterName, image: image)!
        }

        cgImage = Filter.ciImage2cgImage(image: filterImg)
        
        dispatch_sync(dispatch_get_main_queue(), {
            [unowned self ] in
            
            self.previewLayer.contents = nil
            self.previewLayer.contents = cgImage

        })
    }
    
    func faceDetect(rects rects: [CGRect]) {
        var newFaceViews: [UIView] = []
        
        for rect in rects {
            let screenHeight = self.previewLayer.bounds.height
            let screenWidth = self.previewLayer.bounds.width
            let newRect = CGRectMake( screenWidth*rect.origin.y, screenHeight*rect.origin.x, screenWidth*rect.width, screenWidth*rect.height)
            
            let faceView = UIView(frame: newRect)
            faceView.layer.borderWidth = 2
            faceView.layer.borderColor = UIColor.blueColor().CGColor
            newFaceViews.append(faceView)
        }
        
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void  in
            
            for view in self.faceViews {
                view.removeFromSuperview()
            }
            
            self.faceViews.removeAll()
            
            for view in newFaceViews {
                self.mainView.addSubview(view)
                self.faceViews.append(view)
                //print(view.bounds)
            }
        })
    }
}