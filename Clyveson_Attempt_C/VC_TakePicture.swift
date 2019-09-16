//
//  ViewController.swift
//  Clyveson_Attempt_C
//
//  Created by Clyve on 8/17/19.
//  Copyright © 2019 Clyve. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

class VC_TakePicture: UIViewController {

    // MARK: properties
    
    var session: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var globalPhoto: AVCapturePhoto?
    @IBOutlet weak var vidImageView: UIImageView!
    
    
    // MARK: VC functions
    
    // Activated when imageView is clicked
    @objc func singleTapping(recognizer: UIGestureRecognizer) {
        guard let capPhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isDepthDataDeliveryEnabled = true
        
        //  Based on the photoSettings, the photoOutput method is required (which is in the extension below)
        capPhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }
    
    override func viewWillLayoutSubviews() {
        //self.setNavigationBar()
//        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 144))
//        self.view.addSubview(navBar)
    }
    
    // runs when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set navigation bar
//        self.setNavigationBar()
        vidImageView.layer.zPosition = 10
        
        // Makes ImageView act as a button
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTapping(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        vidImageView.addGestureRecognizer(singleTap)
        vidImageView.isUserInteractionEnabled = true
        
        startCameraSession()
    }
    
    // Programatically creates navigation bar
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 344))
        let navItem = UINavigationItem(title: "Fittrex")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(done))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: true)
        navBar.layer.zPosition = 15
        self.view.addSubview(navBar)
    }

    @objc func done() { // remove @objc for Swift 3
    }
    
    
    // MARK: - Navigation
    
    // Prepares for navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showImageSegue"  {
            os_log("Viewing Image", log: OSLog.default, type: .debug)
            
            // sets destination
            let nav = segue.destination as! UINavigationController
            
            guard let phtotoViewController = nav.topViewController as? VC_DrawBox else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            assert(globalPhoto != nil, "You are trying to send over an empty picture!!!")
            
            // set image in receiving controller
            phtotoViewController.snappedPhotoView = globalPhoto
           // phtotoViewController.addingMeal = true
            
        }
    }
    
    
    // MARK: Action Functions
    
    func startCameraSession(){
        // gets permissions for video
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { _ in })
        
        // Back stereo camera --> gives relative depth (disparity)
        let captureDeviceBack = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDeviceBack!)
            
            self.capturePhotoOutput = AVCapturePhotoOutput()
            self.session = AVCaptureSession()
            self.session?.beginConfiguration()
            self.session?.sessionPreset = .photo
            // adds input --> camera
            self.session?.addInput(input)
            
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session!)
            //  sets aspect ratio of app
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            self.videoPreviewLayer?.frame = self.view.layer.bounds
            print("bounds: \(self.view.layer.bounds)")
            // adds our view layer to UI
            self.vidImageView.layer.addSublayer(self.videoPreviewLayer!)
            
            // adds output --> image that camera sees
            self.session?.addOutput(self.capturePhotoOutput!)
            self.session?.commitConfiguration()
            
            // checks that camera is depth enabled
            self.capturePhotoOutput?.isDepthDataDeliveryEnabled = true
            
            assert(self.capturePhotoOutput?.isDepthDataDeliveryEnabled == true, "Camera is not depth-enabled")
            self.session?.startRunning()
        }
        catch{
            // prints built-in error result if something goes wrong with starting the session
            print(error)
        }
    }
    
    
   
}


// ViewController extension used to get depthData values
extension VC_TakePicture : AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // set our globalPhoto
        globalPhoto = photo
        print("globalPhotoSet")
        
        // show image in PhotoViewController
        performSegue(withIdentifier: "showImageSegue", sender: self)
    }
    
    
    
}


