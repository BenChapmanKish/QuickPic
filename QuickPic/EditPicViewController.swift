//
//  EditPicViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-23.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

protocol EditPageDelegate {
    func editPageWillDismiss()
}

class EditPicViewController: UIViewController {

    @IBOutlet var capturedImageView: UIImageView!
    @IBOutlet var editsOverlayView: UIView!
    @IBOutlet var uiOverlayView: UIView!
    
    var capturedImage: UIImage?
    var delegate: EditPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturedImageView.image = self.capturedImage
    }
    
    func configure(withCapturedImage image: UIImage, delegate: EditPageDelegate? = nil) {
        self.capturedImage = image
        self.delegate = delegate
    }
    
    func drawEditsOnCapturedImage() -> UIImage? {
        guard let capturedImage = self.capturedImage else { return nil }
        
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
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        self.saveImageToCameraRoll()
    }
    
    func saveImageToCameraRoll() {
        guard let editedImage = self.drawEditsOnCapturedImage() else {
            self.showGenericErrorAlert(withMessage: UserFacingStrings.Errors.couldNotSaveImage)
            return
        }
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil)
    }

    @IBAction func exitButtonTapped(_ sender: UIButton) {
        self.delegate?.editPageWillDismiss()
        self.dismiss(animated: false, completion: nil)
    }
}
