//
//  CameraViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    @IBOutlet var previewView: UIView!
    @IBOutlet var uiOverlayView: UIView!
    @IBOutlet var editsOverlayView: UIView!
    @IBOutlet var captureButton: UIButton!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCamera()
    }
    
    func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
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
        self.previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        
        captureSession.startRunning()
    }
    
    @IBAction func onCaptureButtonTapped(_ sender: Any) {
        self.captureImage()
    }
    
    func captureImage() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func drawEditsOn(image: UIImage) -> UIImage {
        let layer = self.editsOverlayView.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else { return image }
        
        image.draw(in: layer.frame)
        
        layer.render(in: context)
        guard let screenshotImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext()
        
        return screenshotImage
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
        guard let imageData = photo.fileDataRepresentation(),
        let capturedImage = UIImage.init(data: imageData) else { return }
        
        let screenshotImage = self.drawEditsOn(image: capturedImage)
        
        UIImageWriteToSavedPhotosAlbum(screenshotImage, nil, nil, nil)
    }
}
