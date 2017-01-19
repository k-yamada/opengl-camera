//
//  Camera.swift
//  opengl-camera
//
//  Created by kyamada on 2017/01/19.
//  Copyright © 2017年 kyamada. All rights reserved.
//


import AVFoundation

class Camera {
    private let input: AVCaptureDeviceInput
    private let output: AVCaptureVideoDataOutput
    private var session: AVCaptureSession
    private let captureDevice: AVCaptureDevice
    
    init(delegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh

        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { fatalError() }
        captureDevice = device
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            captureDevice.unlockForConfiguration()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        do {
            input = try AVCaptureDeviceInput(device: device)
            if (session.canAddInput(input)) {
                session.addInput(input)
            }
            
            output = AVCaptureVideoDataOutput()
            if (session.canAddOutput(output)) {
                session.addOutput(output)
            }
            
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
            output.setSampleBufferDelegate(delegate, queue: DispatchQueue.main)
            output.alwaysDiscardsLateVideoFrames = true
            session.startRunning()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func startRunning() {
        session.startRunning()
    }
    
    func stopRunning() {
        session.stopRunning()
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
    }
}
