//
//  ImageUtil.swift
//  camera
//
//  Created by suihong on 16/3/20.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class ImageUtil : NSObject{
    
    static func ImageSave(image image: UIImage) -> Void{
        let ciImg = image.CIImage
        let cgImg = Filter.ciImage2cgImage(image: ciImg!)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(cgImg, metadata: image.CIImage?.properties, completionBlock: { (url: NSURL!, error: NSError!) -> Void in
            if error != nil {
                print("save error:")
                print(error.localizedDescription)
            }else{
                print("save success!")
                print(url)
            }
        })
    }
    
    static func ImageSave(image image: UIImage, path:String) -> Void{
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
    
}