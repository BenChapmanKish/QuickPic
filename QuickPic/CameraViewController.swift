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
    case livePreview(cameraPosition: AVCaptureDevice.Position)
    case capturingImage(cameraPosition: AVCaptureDevice.Position)
    case editing(capturedImage: UIImage)
    
    func cameraPosition() -> AVCaptureDevice.Position? {
        switch self {
        case .livePreview(let position),
             .capturingImage(let position):
            return position
        default:
            return nil
        }
    }
    
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
    @IBOutlet var editsOverlayView: UIView!
    @IBOutlet var capturedImageView: UIImageView!
    
    @IBOutlet var captureButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    var state: CameraPageState = .livePreview(cameraPosition: .back)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSwitchCameraGesture()
        self.setupCamera(forPosition: .back)
    }
    
    func setupCamera(forPosition position: AVCaptureDevice.Position) {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else { return }
        
        self.state = .livePreview(cameraPosition: position)
        
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
        
        self.enterLivePreviewState(withPosition: position)
    }
    
    private func setupSwitchCameraGesture() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.handleTap(_:)))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 2
        self.uiOverlayView.addGestureRecognizer(tapGR)
    }
    
    private func switchCameras() {
        switch self.state {
        case .livePreview(let cameraPosition):
            if cameraPosition == .back {
                self.setupCamera(forPosition: .front)
            } else {
                self.setupCamera(forPosition: .back)
            }
        default:
            break
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
        guard let capturePhotoOutput = self.capturePhotoOutput,
            let cameraPosition = self.state.cameraPosition() else { return }
        
        self.state = .capturingImage(cameraPosition: cameraPosition)
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func drawEditsOnCapturedImage() -> UIImage? {
        guard let capturedImage = self.state.capturedImage() else { return nil }
        
        let layer = self.editsOverlayView.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        capturedImage.draw(in: layer.frame)
        
        layer.render(in: context)
        guard let editedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return editedImage
    }
    
    func enterEditState(withImage image: UIImage, andCameraPosition position: AVCaptureDevice.Position) {
        var flippedImage: UIImage?
        if position == .front,
            let cgimage = image.cgImage {
            flippedImage = UIImage(cgImage: cgimage, scale: image.scale, orientation: .leftMirrored)
        }
        
        
        self.state = .editing(capturedImage: flippedImage ?? image)
        self.editsOverlayView.isHidden = false
        self.capturedImageView.isHidden = false
        self.capturedImageView.image = flippedImage ?? image
        self.captureSession?.stopRunning()
        self.livePreviewView.isHidden = true
    }
    
    func enterLivePreviewState(withPosition position: AVCaptureDevice.Position) {
        self.state = .livePreview(cameraPosition: position)
        self.editsOverlayView.isHidden = true
        self.capturedImageView.isHidden = true
        self.capturedImageView.image = nil
        self.captureSession?.startRunning()
        self.livePreviewView.isHidden = false
    }
    
    func saveImageToCameraRoll() {
        guard let editedImage = self.drawEditsOnCapturedImage() else { return }
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil)
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
        switch self.state {
        case .capturingImage(let position):
            guard let imageData = photo.fileDataRepresentation(),
                let capturedImage = UIImage.init(data: imageData) else { return }
            self.enterEditState(withImage: capturedImage, andCameraPosition: position)
        default:
            self.setupCamera(forPosition: .back)
        }
    }
}

extension CameraViewController : UIGestureRecognizerDelegate {
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        self.switchCameras()
    }
}
