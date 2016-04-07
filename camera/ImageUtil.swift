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
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        
    }
    
    static func ImageSave(image image: UIImage, path:String) -> Void{
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }
    
}