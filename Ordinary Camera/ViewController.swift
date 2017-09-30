//
//  ViewController.swift
//  Ordinary Camera
//
//  Created by DUHUN HWANG on 2017. 9. 28..
//  Copyright © 2017년 YELOBEAN. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum LiveMode {
    
    case on, off, unavailable
}

class ViewController: UIViewController {
    
    // intializing class variable
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var input: AVCaptureDeviceInput?
    var capturePhotoOutput = AVCapturePhotoOutput()
    var imageData: Data?
    var timer = Timer()
    var timerCount = 0
    // \initializing class variable
    
    // initializing option variable
    var flashMode = AVCaptureDevice.FlashMode.off
    var liveMode = LiveMode.on
    var timerMode = 0
    var cameraPosition = AVCaptureDevice.Position.back
    // \initializing option variable
    
    // IB OUTLET
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var timerCountLabel: UILabel!
    // \IB OUTLET
    
    // IB ACTION
    @IBAction func cameraAction(_ sender: UIButton) {
        
        cameraButton.isEnabled = false

        timerCount = timerMode
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.processTimer), userInfo: nil, repeats: true)
 
        
    }
    
    
    // OPTION CONTROL
    @IBAction func camPositionAction(_ sender: UIButton) {
        
        if cameraPosition == AVCaptureDevice.Position.front {
            cameraPosition = AVCaptureDevice.Position.back
        } else {
            cameraPosition = AVCaptureDevice.Position.front
        }
        
        
        
        captureSession.removeInput(captureSession.inputs.first as AVCaptureInput!)
        captureSession.removeOutput(captureSession.outputs.first as AVCaptureOutput!)
        
        captureSession.stopRunning()
        loadCamera()
    }
    
    
    @IBAction func timerAction(_ sender: UIButton) {
        
        if timerMode == 0 {
            timerMode = 3
            timerButton.setTitle("Timer.three", for: UIControlState.normal)
        } else if timerMode == 3 {
            timerMode = 10
            timerButton.setTitle("Timer.ten", for: UIControlState.normal)
        } else {
            timerMode = 0
            timerButton.setTitle("Timer.off", for: UIControlState.normal)
        }
    }
    
    @IBAction func liveAction(_ sender: UIButton) {
        if capturePhotoOutput.isLivePhotoCaptureEnabled == true {
            capturePhotoOutput.isLivePhotoCaptureEnabled = false
            liveMode = .off
            liveButton.setTitle("Live.off", for: UIControlState.normal)
        } else {
            capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
            liveMode = .on
            liveButton.setTitle("Live.on", for: UIControlState.normal)
        }
    }
    
    @IBAction func flashAction(_ sender: UIButton) {
        if flashMode == .off {
            flashMode = .auto
            flashButton.setTitle("Flash.auto", for: UIControlState.normal)
        } else if flashMode == .auto {
            flashMode = .on
            flashButton.setTitle("Flash.on", for: UIControlState.normal)
        } else {
            flashMode = .off
            flashButton.setTitle("Flash.off", for: UIControlState.normal)
        }
    }
    // \OPTION CONTROL
    // \IB ACTION
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // load setting (user defaults)
        liveMode = .on
        timerMode = 0
        cameraPosition = AVCaptureDevice.Position.back
        flashMode = AVCaptureDevice.FlashMode.off
        // \load setting (user defaults)
        
        loadCamera()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // basic function for camera operation
    
    func loadCamera(){
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: cameraPosition) // how to selfie camera
        
        
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession.addInput(input!)
            
            captureSession.addOutput(capturePhotoOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            
            videoPreviewLayer?.frame = previewView.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.sessionPreset = .photo
            
            if !capturePhotoOutput.isLivePhotoCaptureSupported {
                liveMode = .unavailable
                liveButton.alpha = 0
            }
            
            if liveMode == .on {
                capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
            }
            capturePhotoOutput.isHighResolutionCaptureEnabled = true
            
            captureSession.startRunning()
            
        } catch {
            
            print(error)
        }
    }
    
}










// other functions about delegate

extension ViewController : AVCapturePhotoCaptureDelegate {
    
    // delegate
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto: AVCapturePhoto, error: Error?) {
        
        self.imageData = didFinishProcessingPhoto.fileDataRepresentation()
        
        
        if !capturePhotoOutput.isLivePhotoCaptureEnabled {
            let capturedImage = UIImage.init(data: imageData! , scale: 1.0)
            if let image = capturedImage {
                // Save our captured image to photos album
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
        }
        
        cameraButton.isEnabled = true
    }
    
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?){
        
        
        PHPhotoLibrary.shared().performChanges({ [unowned self] in
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: self.imageData!, options: nil)
            
            
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true
            creationRequest.addResource(with: .pairedVideo, fileURL: outputFileURL, options: options)
            
            
            }, completionHandler: {  success, error in
                if let error = error {
                    print("Error occurered while saving photo to photo library: \(error)")
                }
                
                
                if FileManager.default.fileExists(atPath: outputFileURL.path) {
                    do {
                        try FileManager.default.removeItem(atPath: outputFileURL.path)
                    }
                    catch {
                        print("Could not remove file at url: \(outputFileURL.path)")
                    }
                } // change to func? if not exist?
                
        })
    }
    // \delegate
    
    // selector
    @objc func processTimer() {
        
        if timerCount > 0 {
            self.timerCountLabel.alpha = 1
            
            timerCountLabel.text = String(timerCount)
        } else {
            let photoSettings = AVCapturePhotoSettings()
            
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = flashMode
            
            if capturePhotoOutput.isLivePhotoCaptureEnabled {
                let livePhotoMovieFileName = NSUUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
            self.timerCountLabel.alpha = 0
            timer.invalidate()
            
        }
        timerCount -= 1
    }
    
    // \selector
    
}


