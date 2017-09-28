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

class ViewController: UIViewController {

    // intializing class variable
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var input: AVCaptureDeviceInput?
    var capturePhotoOutput = AVCapturePhotoOutput()
    var cameraPosition = AVCaptureDevice.Position.back
    var imageData: Data?
    // \initializing class variable
    
    
    
    // IB OUTLET
    @IBOutlet weak var previewView: UIView!
    
    // \IB OUTLET
    
    
    
    
    // IB ACTION
    @IBAction func cameraAction(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        if capturePhotoOutput.isLivePhotoCaptureEnabled {
                        let livePhotoMovieFileName = NSUUID().uuidString
                        let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                        photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
        }
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    // \IB ACTION
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: cameraPosition) // how to self

        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession.addInput(input!)
            
            captureSession.addOutput(capturePhotoOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            videoPreviewLayer?.frame = previewView.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.sessionPreset = .photo
            
            capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported // option
            capturePhotoOutput.isHighResolutionCaptureEnabled = true
            
            captureSession.startRunning()
            
        } catch {
            
            print(error)
        }

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}










// extension delegate

extension ViewController : AVCapturePhotoCaptureDelegate {
    
    
    
    
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto: AVCapturePhoto, error: Error?) {
        
        self.imageData = didFinishProcessingPhoto.fileDataRepresentation()
        
        
        if !capturePhotoOutput.isLivePhotoCaptureEnabled {
            let capturedImage = UIImage.init(data: imageData! , scale: 1.0)
            if let image = capturedImage {
                // Save our captured image to photos album
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
            
        }
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
                } // change to func?
                
        }
        )
        
    }
}


