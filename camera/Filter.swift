//
//  Filter.swift
//  camera
//
//  Created by suihong on 16/3/22.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation
import CoreImage
import ImageIO
import UIKit

class Filter: NSObject {
    static var faceDetector: CIDetector!
    
    class Context: NSObject {
        private static var context: CIContext!
        private static var predicate: dispatch_once_t = 0
        
        static func defaultContext() -> CIContext {
            dispatch_once(&predicate, { () -> Void in
                //Context.context = CIContext(options: nil)
                let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
                let options = [kCIContextWorkingColorSpace : NSNull()]
                Context.context = CIContext(EAGLContext: eaglContext, options: options)
            })
            return Context.context
        }
    }
    
    static func filterImage(filterName name:String, image:CIImage) -> CIImage? {
        
        if name.isEmpty
        {
            return nil
        }
        
        let filter = CIFilter(name: name)
        filter?.setValue(image, forKey: kCIInputImageKey)
        let output = filter?.outputImage
        //output = output?.imageByApplyingOrientation(6)
        //let context = Context.defaultContext()
        //let outputImg = context.createCGImage(output!, fromRect: output!.extent)
        return output
    }
    
    static func faceFilter(image: CIImage) -> [CIFeature]? {
//        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: Context.defaultContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
//        
        if faceDetector == nil {
            faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: Context.defaultContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        }
        var faceFeature : [CIFeature]!
        if let orientation = image.properties[kCGImagePropertyOrientation as String] {
            faceFeature = faceDetector.featuresInImage(image, options: [CIDetectorImageOrientation: orientation])
        } else{
            faceFeature = faceDetector.featuresInImage(image)
        }
        
        return faceFeature
    }
    
    static func ciImage2cgImage(image image:CIImage) -> CGImage {
        let context = Context.defaultContext()
        
        let outputImg = context.createCGImage(image, fromRect: image.extent)
        
        return outputImg
    }
    
}