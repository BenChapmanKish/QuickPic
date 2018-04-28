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
    @IBOutlet var flashIndicatorButton: QPButton!
    
    private var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var capturePhotoOutput: AVCapturePhotoOutput?
    
    private var state: CameraPageState = .livePreview
    private var flashMode: AVCaptureDevice.FlashMode = .auto
    private var cameraPosition: AVCaptureDevice.Position = .back
    
    private var zoomScale: CGFloat = 1.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSwitchCameraGesture()
        self.setupPinchToZoomGesture()
        self.setupCamera()
        
        if let lastFlashModeInt = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastFlashMode) as? Int,
            let lastFlashMode = AVCaptureDevice.FlashMode(rawValue: lastFlashModeInt) {
            self.setFlashMode(to: lastFlashMode)
        }
    }
    
    private func setupCamera(forPosition cameraPosition: AVCaptureDevice.Position? = nil) {
        let position = cameraPosition ?? self.cameraPosition
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
        self.captureDevice = captureDevice
        
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
    
    private func setupPinchToZoomGesture() {
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.uiOverlayView.addGestureRecognizer(pinchGR)
    }
    
    private func setupSwitchCameraGesture() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 2
        self.uiOverlayView.addGestureRecognizer(tapGR)
    }
    
    public func switchCameras() {
        self.setVideoZoomScale(to: 1.0)
        if self.cameraPosition == .back {
            self.setupCamera(forPosition: .front)
        } else {
            self.setupCamera(forPosition: .back)
        }
    }
    
    @IBAction func flashButtonTapped(_ sender: QPButton) {
        self.cycleFlashMode()
    }
    
    public func cycleFlashMode() {
        switch self.flashMode {
        case .on:
            self.setFlashMode(to: .auto)
        case .auto:
            self.setFlashMode(to: .off)
        case .off:
            self.setFlashMode(to: .on)
        }
    }
    
    public func setFlashMode(to flashMode: AVCaptureDevice.FlashMode) {
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
    
    @IBAction func swapCameraButtonTapped(_ sender: QPButton) {
        self.switchCameras()
    }
    
    @IBAction func captureButtonTapped(_ sender: QPButton) {
        switch self.state {
        case .livePreview:
            self.captureImage()
        case .preparingToEdit:
            self.setupCamera(forPosition: .back)
        default:
            break
        }
    }
    
    public func captureImage() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        self.state = .capturingImage
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = self.flashMode
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    private func enterEditState(withImage image: UIImage) {
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
    
    private func setVideoZoomScale(to zoomScale: CGFloat) {
        guard let captureDevice = self.captureDevice else { return }
        
        do {
            try captureDevice.lockForConfiguration()
            
            self.zoomScale = max(1.0, min(zoomScale,  captureDevice.activeFormat.videoMaxZoomFactor, Constants.Camera.maxZoomFactor))
            captureDevice.videoZoomFactor = self.zoomScale
            
            captureDevice.unlockForConfiguration()
        } catch {
            return
        }
    }
}



extension CameraViewController : UIGestureRecognizerDelegate {
    @objc func handleDoubleTapGesture(_ gesture: UITapGestureRecognizer){
        self.switchCameras()
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            let desiredZoomScale = self.zoomScale + atan2(gesture.velocity, Constants.Camera.pinchVelocityDivisionFactor)
            self.setVideoZoomScale(to: desiredZoomScale)
        default:
            break
        }
    }
}

extension CameraViewController : EditPageDelegate {
    func editPageWillDismiss() {
        if let captureSession = self.captureSession {
            self.state = .livePreview
            self.setVideoZoomScale(to: 1.0)
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
