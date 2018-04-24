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
    
    @IBOutlet var textBarContainer: UIView!
    @IBOutlet var textBarTextView: UITextView!
    
    var capturedImage: UIImage?
    var delegate: EditPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturedImageView.image = self.capturedImage
        self.setupTextBar()
    }
    
    func configure(withCapturedImage image: UIImage, delegate: EditPageDelegate? = nil) {
        self.capturedImage = image
        self.delegate = delegate
    }
    
    private func setupTextBar() {
        self.textBarContainer.isHidden = true
        self.textBarTextView.delegate = self
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(EditPicViewController.handleSingleTap(_:)))
        tapGR.delegate = self
        // Add gesture to edits overlay view since ui overlay view passes through taps
        self.editsOverlayView.addGestureRecognizer(tapGR)
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
    
    @IBAction func addTextButtonTapped(_ sender: UIButton) {
        if self.textBarContainer.isHidden {
            self.showTextBar()
        }
    }
    
    private func showTextBar() {
        self.textBarContainer.isHidden = false
        self.textBarTextView.becomeFirstResponder()
    }
    
    private func dismissTextBarAndHideIfEmpty() {
        if self.textBarTextView.text.isEmpty {
            self.textBarContainer.isHidden = true
        }
        self.textBarTextView.resignFirstResponder()
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        self.delegate?.editPageWillDismiss()
        self.dismiss(animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension EditPicViewController : UIGestureRecognizerDelegate {
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer){
        if self.textBarContainer.isHidden {
            self.showTextBar()
        } else {
            self.dismissTextBarAndHideIfEmpty()
        }
    }
}

extension EditPicViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.textBarTextView,
            text == "\n" {
            self.dismissTextBarAndHideIfEmpty()
            return false
        }
        return true
    }
}
