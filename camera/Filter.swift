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
    
    static func facePixellate(image image: CIImage, faceRects: [CGRect], height: CGFloat, width: CGFloat, reverseX: Bool, reverseY: Bool) -> CIImage? {
        
        if faceRects.count <= 0 {
            return nil
        }
        
        let filter = CIFilter(name: "CIPixellate")
        print(filter)
        
        //let imgHeight = image.extent.width
        //let imgWidth = image.extent.height
        
        let imgWidth = image.extent.width
        let imgHeight = image.extent.height
        
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(20.0, forKey: kCIInputScaleKey)
        filter?.setValue(CIVector(x: imgWidth, y:imgHeight), forKey: kCIInputCenterKey)
        let pixellatedImg = filter?.outputImage
        
        var maskImg: CIImage!
        
        for rect in faceRects {
            print("-------rect")
            print(rect)
            print("-------rect")
            var centerX = rect.origin.x*imgWidth+rect.width*imgWidth*0.5000
            var centerY = rect.origin.y*imgHeight+rect.height*imgHeight*0.5000
            //let centerX = rect.origin.y*imgHeight+rect.height*imgHeight*0.5
            //var centerY = rect.origin.x*imgWidth+rect.width*imgWidth*0.5
            if reverseX
            {
                centerX = imgWidth-centerX
            }
            
            if reverseY
            {
                centerY = imgHeight-centerY
            }
//            let centerX = rect.origin.y*imgWidth+rect.height*imgWidth*0.5
//            let centerY = rect.origin.x*imgHeight+rect.width*imgHeight*0.5
//            let centerX = (width-rect.origin.x-rect.width)*0.5
//            let centerY = (height-rect.origin.y-rect.height)*0.5
            print("--------centerx")
            print(centerX)
            print("--------centerx")
            
            print("--------centery")
            print(centerY)
            print("--------centery")
            
            let radius = min(rect.width*imgWidth*0.5,rect.height*imgHeight*0.5)
            print("---radius:")
            print(radius)
            print("-----")
            
            let radialGradient = CIFilter(name: "CIRadialGradient", withInputParameters: [
                "inputRadius0":radius,
                "inputRadius1":radius+1,
                "inputColor0":CIColor(red: 0, green: 1, blue: 0, alpha: 1),
                "inputColor1":CIColor(red: 0, green: 0, blue: 0, alpha: 0),
                kCIInputCenterKey : CIVector(x: centerX, y: centerY)
                ])
            let ciV = CIVector(x: centerX, y: centerY)
            print(ciV.CGRectValue)
            print(ciV.CGPointValue)
            //print(radialGradient?.attributes)

            
            let radialGradientOutputImg = radialGradient?.outputImage?.imageByCroppingToRect(image.extent)
            //radialGradientOutputImg = radialGradientOutputImg?.imageByApplyingTransform(CGAffineTransformMakeScale(1, -1))

            print("-------image")
            print(image.extent)
            print("-------image")
            
            print("-------outputImg")
            print((radialGradientOutputImg?.extent)!)
            print("-------outputImg")
            
            if maskImg == nil {
                maskImg = radialGradientOutputImg
            }
            else{
                maskImg = CIFilter(name: "CISourceOverCompositing", withInputParameters: [
                    kCIInputImageKey:radialGradientOutputImg!,
                    kCIInputBackgroundImageKey:maskImg
                    ])?.outputImage
            }
        }
        
        let blendFilter = CIFilter(name: "CIBlendWithMask")
        blendFilter?.setValue(pixellatedImg, forKey: kCIInputImageKey)
        blendFilter?.setValue(image, forKey: kCIInputBackgroundImageKey)
        blendFilter?.setValue(maskImg, forKey: kCIInputMaskImageKey)
        
        return blendFilter?.outputImage
    }
    
}