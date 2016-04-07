//
//  Camera.swift
//  camera
//
//  Created by suihong on 16/3/23.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum CameraError: ErrorType {
    case CreateSession
    case AddInput
    case AddOutput
}

public protocol CameraDelegate : NSObjectProtocol{
    func dealWithImage(image image: CIImage) -> Void
    
    func faceBound(rects rects: [CGRect]) -> Void
}

class Camera : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate{
    
    private var deviceInput: AVCaptureDeviceInput!
    private var deviceStillImageOutput: AVCaptureStillImageOutput!
    private var deviceDataOutput: AVCaptureVideoDataOutput!
    private var deviceMetaDataOutput: AVCaptureMetadataOutput!
    private var context :CIContext!
    private var session :AVCaptureSession!
    
    
    
    weak var delegate: CameraDelegate!
    
    override init() {
        
        super.init()
        
        session = AVCaptureSession()
        
        session.beginConfiguration()
        
        //session.sessionPreset = AVCaptureSessionPresetHigh
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        let device = self.getDevice(position: .Back)
        do {
            try deviceInput = AVCaptureDeviceInput.init(device: device)
        }catch {
            print("cant init input device")
        }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
            //session.sessionPreset = AVCaptureSessionPresetPhoto
        }
        
        deviceDataOutput = AVCaptureVideoDataOutput()
        
        deviceDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber.init(unsignedInt: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        deviceDataOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(deviceDataOutput) {
            session.addOutput(deviceDataOutput)
        }
        let queue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL)
        deviceDataOutput.setSampleBufferDelegate(self, queue: queue)
        
        
        deviceMetaDataOutput = AVCaptureMetadataOutput()
        let metaDataQueue = dispatch_queue_create("MetaDataQueue", DISPATCH_QUEUE_SERIAL)
        deviceMetaDataOutput.setMetadataObjectsDelegate(self, queue: metaDataQueue)
        if session.canAddOutput(deviceMetaDataOutput) {
            session.addOutput(deviceMetaDataOutput)
            print("add device metadata output")
        }
        deviceMetaDataOutput.metadataObjectTypes.append(AVMetadataObjectTypeFace)
        print(deviceMetaDataOutput.availableMetadataObjectTypes)
        
        session.commitConfiguration()
        
        //context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        context = CIContext(EAGLContext: eaglContext, options: options)
    }
    
    func startCapture() -> Void {
        session.startRunning()
    }
    
    func stopCapture() -> Void {
        session.stopRunning()
    }
    
    func capture() -> CGImage? {
        stopCapture()
        startCapture()
        return nil
    }
    
    func shutterCamera() -> Void {
        
        self.stopCapture()
        
        session.beginConfiguration()
            
        var pos: AVCaptureDevicePosition = AVCaptureDevicePosition.Front;
        if self.deviceInput.device.position == AVCaptureDevicePosition.Front {
            pos = AVCaptureDevicePosition.Back
        } else if self.deviceInput.device.position == AVCaptureDevicePosition.Back {
            pos = AVCaptureDevicePosition.Front
        }
            
        self.session.removeInput(self.deviceInput)
        self.deviceInput = nil
            
        let device = self.getDevice(position: pos)
        if device == nil {
            //return false
        }
        
        do {
            try self.deviceInput = AVCaptureDeviceInput.init(device: device)
        }catch {
            print("cant add device input")
            //return false
        }
            
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
            
        session.commitConfiguration()
        //session.startRunning()
        self.startCapture()
        //return true
    }
    
    private func getDevice(position pos: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == pos {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    //MARK: - AVCapture代理
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        if delegate != nil {
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
            var outputImg = CIImage(CVPixelBuffer: imageBuffer!)
//            if deviceInput.device.position == AVCaptureDevicePosition.Back {
//                outputImg = outputImg.imageByApplyingOrientation(6)
//            }else if(deviceInput.device.position == AVCaptureDevicePosition.Front) {
//                outputImg = outputImg.imageByApplyingOrientation(5)
//            }
            //let cgImg = context.createCGImage(outputImg, fromRect: outputImg.extent)
            
            delegate.dealWithImage(image: outputImg)
        }
    }
    
    //MARK: - AVDeviceMetaDataOutputDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if delegate == nil {
            return
        }
        
        var rects: [CGRect] = []
        for obj in metadataObjects {
            if obj.type != AVMetadataObjectTypeFace {
                continue
            }
            
            let faceObj = obj as! AVMetadataFaceObject
            if faceObj.hasRollAngle {
                print("roll angle:")
                print(faceObj.rollAngle)
            }
            
            if faceObj.hasYawAngle {
                print("yaw angle")
                print(faceObj.yawAngle)
            }
            //print(faceObj.bounds)
            rects.append(faceObj.bounds)
        }
        
        delegate.faceBound(rects: rects)
    }
    
}