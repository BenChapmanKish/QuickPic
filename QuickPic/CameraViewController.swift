//
//  CameraViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraPageState {
    case livePreview
    case capturingImage
    case editing(capturedImage: UIImage)
    
    func capturedImage() -> UIImage? {
        switch self {
        case .editing(let image):
            return image
        default:
            return nil
        }
    }
}

class CameraViewController: UIViewController {
    @IBOutlet var livePreviewView: UIView!
    @IBOutlet var uiOverlayView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    
    var state: CameraPageState = .livePreview
    var cameraPosition: AVCaptureDevice.Position = .back
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSwitchCameraGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupCamera(forPosition: self.cameraPosition)
    }
    
    func setupCamera(forPosition position: AVCaptureDevice.Position) {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
        
        self.state = .livePreview
        self.cameraPosition = position
        
        // teardown
        self.captureSession?.stopRunning()
        self.livePreviewView.layer.sublayers?.forEach {
            $0.removeFromSuperlayer()
        }
        
        var input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            self.showAlertWithOkButton(message: error.localizedDescription)
            return
        }
        
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        
        captureSession.addInput(input)
        
        
        let capturePhotoOutput = AVCapturePhotoOutput()
        
        self.capturePhotoOutput = capturePhotoOutput
        
        captureSession.addOutput(capturePhotoOutput)
        
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.videoPreviewLayer = videoPreviewLayer
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = self.view.layer.bounds
        self.livePreviewView.layer.addSublayer(videoPreviewLayer)
        
        
        captureSession.startRunning()
    }
    
    private func setupSwitchCameraGesture() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.handleDoubleTap(_:)))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 2
        self.uiOverlayView.addGestureRecognizer(tapGR)
    }
    
    private func switchCameras() {
        if self.cameraPosition == .back {
            self.setupCamera(forPosition: .front)
        } else {
            self.setupCamera(forPosition: .back)
        }
    }
    
    
    @IBAction func onCaptureButtonTapped(_ sender: Any) {
        switch self.state {
        case .livePreview:
            self.captureImage()
        case .editing:
            self.setupCamera(forPosition: .back)
        default:
            break
        }
    }
    
    func captureImage() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        self.state = .capturingImage
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func enterEditState(withImage image: UIImage) {
        var correctedImage: UIImage = image
        
        // If front-facing camera, flip the image horizontally
        if self.cameraPosition == .front,
            let cgimage = image.cgImage {
            correctedImage = UIImage(cgImage: cgimage, scale: image.scale, orientation: .leftMirrored)
        }
        
        self.state = .editing(capturedImage: correctedImage)
        
        self.performSegue(withIdentifier: "showEditPicVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditPicVC" {
            guard let editPicVC = segue.destination as? EditPicViewController else { return }
            
            editPicVC.capturedImage = self.state.capturedImage()
            self.captureSession?.stopRunning()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.showAlertWithOkButton(title: "An error happened", message: error.localizedDescription)
            return
        }
        
        switch self.state {
        case .capturingImage:
            guard let imageData = photo.fileDataRepresentation(),
                let capturedImage = UIImage.init(data: imageData) else { return }
            self.enterEditState(withImage: capturedImage)
        default:
            self.setupCamera(forPosition: .back)
        }
    }
}

extension CameraViewController : UIGestureRecognizerDelegate {
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer){
        self.switchCameras()
    }
}
