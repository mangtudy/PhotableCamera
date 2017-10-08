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
    var currentFilter = 0
    var collectionViewGesture: UICollectionView!
    var longPressGesture: UILongPressGestureRecognizer!
    // \initializing class variable
    
    // initializing option variable
    var flashMode = AVCaptureDevice.FlashMode.off
    var liveMode = LiveMode.on
    var timerMode = 0
    var cameraPosition = AVCaptureDevice.Position.back
    
    var filterDictionary = [Dictionary<String, String>()]
    // \initializing option variable
    
    // IB OUTLET
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var timerCountLabel: UILabel!
    
    @IBOutlet weak var deleteFilterButton: UIButton!
    @IBOutlet weak var tuningFilterButton: UIButton!
    @IBOutlet weak var appendButton: UIButton!
    @IBOutlet weak var modifiedButton: UIButton!
    
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var tuningCollectionView: UICollectionView!
    // \IB OUTLET
    
    // IB ACTION
    @IBAction func cameraAction(_ sender: UIButton) {
        
        cameraButton.isEnabled = false

        timerCount = timerMode
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.processTimer), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func deleteFilterAction(_ sender: UIButton) {
        
        
        if filterDictionary.count > 1 {
            
            filterDictionary.remove(at: currentFilter)
            
            if currentFilter > 0 {
                
                currentFilter -= 1
                UserDefaults.standard.set(currentFilter, forKey: "CurrentFilter")
            }
            print(currentFilter)
            
            filterCollectionView.reloadData()
            
            
            // border
//            var cell: UICollectionViewCell?
//            for i in 0..<filterDictionary.count {
//
//                cell = filterCollectionView.cellForItem(at: IndexPath.init(row: i, section: 0))
//
//                if i == currentFilter {
//                    cell?.layer.borderWidth = 2.0
//                    cell?.layer.borderColor = UIColor.red.cgColor
//                }
//                cell?.layer.borderWidth = 0
//
//            }
        }
    }
    
    @IBAction func tuningFilterAction(_ sender: UIButton) {
        
        tuningCollectionView.alpha = 1
        filterCollectionView.alpha = 0
        collectionViewGesture = tuningCollectionView
        
        tuningFilterButton.alpha = 0
        deleteFilterButton.alpha = 0
        appendButton.alpha = 1
        modifiedButton.alpha = 1
        
    }
    
    @IBAction func appendAction(_ sender: UIButton) {
        
        // change the filter option value
        // \change the filter option value
        
        // add the filter at the end of filterCollectionView
        filterDictionary.append(["name":"ZZ","bright":"1","forcusing":"0.5"])
        // add the filter at the end of filterCollectionView
        
        tuningCollectionView.alpha = 0
        filterCollectionView.alpha = 1
        collectionViewGesture = filterCollectionView
        
        tuningFilterButton.alpha = 1
        deleteFilterButton.alpha = 1
        appendButton.alpha = 0
        modifiedButton.alpha = 0
        
        filterCollectionView.reloadData()
    }
    
    @IBAction func modifiedAction(_ sender: UIButton) {
        
        // change the filter option value
        // \change the filter option value
        
        tuningCollectionView.alpha = 0
        filterCollectionView.alpha = 1
        collectionViewGesture = filterCollectionView
        
        tuningFilterButton.alpha = 1
        deleteFilterButton.alpha = 1
        appendButton.alpha = 0
        modifiedButton.alpha = 0
        
    }
    
    // OPTION CONTROL
    @IBAction func camPositionAction(_ sender: UIButton) {
        
        if cameraPosition == AVCaptureDevice.Position.front {
            cameraPosition = AVCaptureDevice.Position.back
            UserDefaults.standard.set("back", forKey: "CameraPosition")
        } else {
            cameraPosition = AVCaptureDevice.Position.front
            UserDefaults.standard.set("front", forKey: "CameraPosition")
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
            UserDefaults.standard.set("3", forKey: "Timer")
        } else if timerMode == 3 {
            timerMode = 10
            timerButton.setTitle("Timer.ten", for: UIControlState.normal)
            UserDefaults.standard.set("10", forKey: "Timer")
        } else {
            timerMode = 0
            timerButton.setTitle("Timer.off", for: UIControlState.normal)
            UserDefaults.standard.set("0", forKey: "Timer")
        }
    }
    
    @IBAction func liveAction(_ sender: UIButton) {
        if capturePhotoOutput.isLivePhotoCaptureEnabled == true {
            capturePhotoOutput.isLivePhotoCaptureEnabled = false
            liveMode = .off
            liveButton.setTitle("Live.off", for: UIControlState.normal)
            UserDefaults.standard.set("off", forKey: "Live")
        } else {
            capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
            liveMode = .on
            liveButton.setTitle("Live.on", for: UIControlState.normal)
            UserDefaults.standard.set("on", forKey: "Live")
        }
    }
    
    @IBAction func flashAction(_ sender: UIButton) {
        if flashMode == .off {
            flashMode = .auto
            flashButton.setTitle("Flash.auto", for: UIControlState.normal)
            UserDefaults.standard.set("auto", forKey: "Flash")
        } else if flashMode == .auto {
            flashMode = .on
            flashButton.setTitle("Flash.on", for: UIControlState.normal)
            UserDefaults.standard.set("on", forKey: "Flash")
        } else {
            flashMode = .off
            flashButton.setTitle("Flash.off", for: UIControlState.normal)
            UserDefaults.standard.set("off", forKey: "Flash")
        }
    }
    // \OPTION CONTROL
    // \IB ACTION
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // intial Condition of App
        collectionViewGesture = filterCollectionView
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        filterCollectionView.addGestureRecognizer(longPressGesture)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        tuningCollectionView.addGestureRecognizer(longPressGesture)
        
        tuningCollectionView.alpha = 0
        tuningFilterButton.alpha = 1
        deleteFilterButton.alpha = 1
        appendButton.alpha = 0
        modifiedButton.alpha = 0
        // \intial Condition of App
        
        // load setting (user defaults)
        if let flashMode_init = UserDefaults.standard.object(forKey: "Flash") as? String {
            
            if flashMode_init == "off" {
                flashButton.setTitle("Flash.off", for: UIControlState.normal)
                flashMode = .off
            } else if flashMode_init == "auto" {
                flashButton.setTitle("Flash.auto", for: UIControlState.normal)
                flashMode = .auto
            } else {
                flashButton.setTitle("Flash.on", for: UIControlState.normal)
                flashMode = .on
            }
        }
        
        if let live_init = UserDefaults.standard.object(forKey: "Live") as? String {
            
            if live_init == "off" {
                liveButton.setTitle("Live.off", for: UIControlState.normal)
                liveMode = .off
                capturePhotoOutput.isLivePhotoCaptureEnabled = false
            } else {
                liveButton.setTitle("Live.on", for: UIControlState.normal)
                liveMode = .on
                capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
            }
        }
        
        if let timer_init = UserDefaults.standard.object(forKey: "Timer") as? String {
            
            if timer_init == "3" {
                timerMode = 3
                timerButton.setTitle("Timer.three", for: UIControlState.normal)
            } else if timer_init == "10" {
                timerMode = 10
                timerButton.setTitle("Timer.ten", for: UIControlState.normal)
            } else {
                timerMode = 0
                timerButton.setTitle("Timer.off", for: UIControlState.normal)
            }
        }
        
        if let cameraPosition_init = UserDefaults.standard.object(forKey: "CameraPosition") as? String {
            
            if cameraPosition_init == "front" {
                cameraPosition = AVCaptureDevice.Position.front
            } else {
                cameraPosition = AVCaptureDevice.Position.back
            }
        }
        
        if let currentFilter_init = UserDefaults.standard.object(forKey: "CurrentFilter") as? Int {
        
            currentFilter = currentFilter_init
        }
        // \load setting (user defaults)
        
        // load Filter Dictionary
        if filterDictionary.count == 1 && filterDictionary[0].count == 0 {
            filterDictionary.remove(at: 0)
        }
        filterDictionary.append(["name":"AA","bright":"1","forcusing":"0.5"])
        filterDictionary.append(["name":"BB","bright":"2","forcusing":"0.3"])
        filterDictionary.append(["name":"CC","bright":"3","forcusing":"0.2"])
        filterDictionary.append(["name":"DD","bright":"4","forcusing":"0.1"])
        filterDictionary.append(["name":"EE","bright":"5","forcusing":"0.9"])
        filterDictionary.append(["name":"FF","bright":"6","forcusing":"0.8"])
        filterDictionary.append(["name":"GG","bright":"7","forcusing":"0.7"])
        filterDictionary.append(["name":"HH","bright":"8","forcusing":"0.6"])
        filterDictionary.append(["name":"II","bright":"9","forcusing":"0.5"])
        // \load Filter Dictionary
        
        collectionView(filterCollectionView, didSelectItemAt: IndexPath.init(row: currentFilter, section: 0))
        
        loadCamera()
        
    }
    
    // turn on app (select Item before)
//    override func viewDidAppear(_ animated: Bool) {
//
//        super.viewDidAppear(true)
//
//        collectionView(filterCollectionView, didSelectItemAt: IndexPath.init(row: currentFilter, section: 0))
//    }
    
    
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










// other functions about photo capture delegate and selector
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
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionViewGesture.indexPathForItem(at: gesture.location(in: collectionViewGesture)) else {
                break
            }
            collectionViewGesture.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionViewGesture.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionViewGesture.endInteractiveMovement()
        default:
            collectionViewGesture.cancelInteractiveMovement()
        }
    }
    // \selector
    
}


// other functions about uicollection delegate and datasource
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == filterCollectionView {
            
            return filterDictionary.count
        } else {
            
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == filterCollectionView {
            
            /////// test code
            if filterDictionary[indexPath.row]["bright"] == "2" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
                cell.backgroundColor = UIColor.black
                
                return cell
            } else if filterDictionary[indexPath.row]["bright"] == "3" {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
                cell.backgroundColor = UIColor.orange
                
                return cell
                
            } else {
            /////// \test code
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath)
            cell.backgroundColor = UIColor.green
            
            return cell
            /////// test code
            }
            /////// \test code
        } else {
            // modified when more collection view is needed
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TuningCell", for: indexPath)
            cell.backgroundColor = UIColor.blue
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == filterCollectionView {
            currentFilter = indexPath.row
            UserDefaults.standard.set(currentFilter, forKey: "CurrentFilter")
        }
        
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
        print(indexPath.row)
        
//        let cell2 = collectionView.cellForItem(at: indexPath)
//        cell2?.layer.borderWidth = 2.0
//        cell2?.layer.borderColor = UIColor.red.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print(filterDictionary)
        
        let tempList = filterDictionary[sourceIndexPath.row]
        
        filterDictionary.remove(at: sourceIndexPath.row)
        filterDictionary.insert(tempList, at: destinationIndexPath.row)
        
        print(filterDictionary)
        
        print("\(sourceIndexPath.item) \(destinationIndexPath.item)")
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}


