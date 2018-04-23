//
//  CameraViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import AVFoundation

enum CameraPageState: Equatable {
    case livePreview
    case capturingImage
    case preparingToEdit(image: UIImage)
    
    func capturedImage() -> UIImage? {
        switch self {
        case .preparingToEdit(let image):
            return image
        default:
            return nil
        }
    }
}

class CameraViewController: UIViewController {
    @IBOutlet var livePreviewView: UIView!
    @IBOutlet var uiOverlayView: UIView!
    @IBOutlet var flashIndicatorButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    
    var state: CameraPageState = .livePreview
    var flashMode: AVCaptureDevice.FlashMode = .auto
    var cameraPosition: AVCaptureDevice.Position = .back
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSwitchCameraGesture()
        self.setupCamera()
        
        if let lastFlashModeInt = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastFlashMode) as? Int,
            let lastFlashMode = AVCaptureDevice.FlashMode(rawValue: lastFlashModeInt) {
            self.setFlashMode(to: lastFlashMode)
        }
    }
    
    func setupCamera(forPosition cameraPosition: AVCaptureDevice.Position? = nil) {
        let position = cameraPosition ?? self.cameraPosition
        
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
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
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
    
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        self.cycleFlashMode()
    }
    
    func cycleFlashMode() {
        switch self.flashMode {
        case .on:
            self.setFlashMode(to: .auto)
        case .auto:
            self.setFlashMode(to: .off)
        case .off:
            self.setFlashMode(to: .on)
        }
    }
    
    func setFlashMode(to flashMode: AVCaptureDevice.FlashMode) {
        self.flashMode = flashMode
        switch flashMode {
        case .on:
            self.flashIndicatorButton.setImage(#imageLiteral(resourceName: "Flash-On"), for: .normal)
        case .auto:
            self.flashIndicatorButton.setImage(#imageLiteral(resourceName: "Flash-Auto"), for: .normal)
        case .off:
            self.flashIndicatorButton.setImage(#imageLiteral(resourceName: "Flash-Off"), for: .normal)
        }
        UserDefaults.standard.set(self.flashMode.rawValue, forKey: UserDefaultsKeys.lastFlashMode)
    }
    
    @IBAction func swapCameraButtonTapped(_ sender: UIButton) {
        self.switchCameras()
    }
    
    @IBAction func captureButtonTapped(_ sender: Any) {
        switch self.state {
        case .livePreview:
            self.captureImage()
        case .preparingToEdit:
            self.setupCamera(forPosition: .back)
        default:
            break
        }
    }
    
    func captureImage() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        self.state = .capturingImage
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = self.flashMode
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func enterEditState(withImage image: UIImage) {
        var correctedImage: UIImage = image
        
        // If front-facing camera, flip the image horizontally
        if self.cameraPosition == .front,
            let cgimage = image.cgImage {
            correctedImage = UIImage(cgImage: cgimage, scale: image.scale, orientation: .leftMirrored)
        }
        
        self.state = .preparingToEdit(image: correctedImage)
        
        self.performSegue(withIdentifier: Ids.Segues.showEditPicVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Ids.Segues.showEditPicVC {
            guard let editPicVC = segue.destination as? EditPicViewController,
                let capturedImage = self.state.capturedImage() else { return }
            
            editPicVC.configure(withCapturedImage: capturedImage, delegate: self)
            self.captureSession?.stopRunning()
        }
    }
}

extension CameraViewController : EditPageDelegate {
    func editPageWillDismiss() {
        if let captureSession = self.captureSession {
            self.state = .livePreview
            captureSession.startRunning()
        } else {
            self.setupCamera()
        }
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
            return
        }
        
        if self.state == .capturingImage {
            guard let imageData = photo.fileDataRepresentation(),
                let capturedImage = UIImage.init(data: imageData) else { return }
            self.enterEditState(withImage: capturedImage)
        }
    }
}

extension CameraViewController : UIGestureRecognizerDelegate {
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer){
        self.switchCameras()
    }
}
