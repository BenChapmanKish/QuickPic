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
    
    @IBOutlet var textBarTopConstraint: NSLayoutConstraint!
    @IBOutlet var textBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var textBarContainer: UIView!
    @IBOutlet var textBarTextView: UITextView!
    
    var capturedImage: UIImage?
    var delegate: EditPageDelegate?
    var textBarInitialPositionForGesture: CGFloat = 0.0
    var textBarPosition: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturedImageView.image = self.capturedImage
        self.setupTextBar()
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)*/
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
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(EditPicViewController.handlePanGesture(_:)))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        self.textBarContainer.addGestureRecognizer(panGR)
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
        } else {
            self.textBarTextView.becomeFirstResponder()
        }
    }
    
    private func showTextBar(atHeight height: CGFloat? = nil) {
        let barHeight = height ?? self.view.frame.height / 2
        self.textBarContainer.isHidden = false
        self.textBarPosition = barHeight
        self.textBarTopConstraint.constant = barHeight
        self.textBarTextView.becomeFirstResponder()
    }
    
    private func dismissTextBarAndHideIfEmpty() {
        self.textBarTextView.resignFirstResponder()
        if self.textBarTextView.text.isEmpty {
            self.textBarContainer.isHidden = true
        }
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        self.delegate?.editPageWillDismiss()
        self.dismiss(animated: false, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*@objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        self.editsOverlayBottomConstraint.constant = keyboardFrame.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.editsOverlayBottomConstraint.constant = 0
    }*/
}

extension EditPicViewController : UIGestureRecognizerDelegate {
    @objc func handleSingleTap(_ gesture: UITapGestureRecognizer){
        if self.textBarContainer.isHidden {
            self.showTextBar(atHeight: gesture.location(in: self.editsOverlayView).y)
        } else {
            self.dismissTextBarAndHideIfEmpty()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer){
        guard self.textBarContainer == gesture.view,
            !self.textBarContainer.isHidden,
            !self.textBarTextView.isFirstResponder else { return }
        
        let translation = gesture.translation(in: self.view).y
        
        
        switch gesture.state {
        case .began:
            self.textBarInitialPositionForGesture = self.textBarPosition
        case .changed:
            self.textBarPosition = self.textBarInitialPositionForGesture + translation
            
            self.textBarPosition = max(self.textBarPosition, 0)
            self.textBarPosition = min(self.textBarPosition, self.editsOverlayView.frame.height - self.textBarContainer.frame.height)
            self.textBarTopConstraint.constant = self.textBarPosition
        default:
            break
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
