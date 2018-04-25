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

// TODO: Organize methods

class EditPicViewController: UIViewController {

    @IBOutlet var capturedImageView: UIImageView!
    @IBOutlet var editsOverlayView: UIView!
    @IBOutlet var uiOverlayView: UIView!
    
    @IBOutlet var saveButton: QPButton!
    
    @IBOutlet var timePickerContainer: UIView!
    @IBOutlet var timePickerView: UIPickerView!
    
    @IBOutlet var textBarTopConstraint: NSLayoutConstraint!
    @IBOutlet var textBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var textBarContainer: UIView!
    @IBOutlet var textBarTextView: UITextView!
    
    private var capturedImage: UIImage?
    private var picDisplayTime: Int = Constants.PicDisplay.defaultDisplayTime
    
    private var delegate: EditPageDelegate?
    private var textBarInitialPositionForGesture: CGFloat = 0.0
    private var textBarPosition: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.capturedImageView.image = self.capturedImage
        self.setupTextBar()
        self.setupPickerView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    public func configure(withCapturedImage image: UIImage, delegate: EditPageDelegate? = nil) {
        self.capturedImage = image
        self.delegate = delegate
    }
    
    private func setupTextBar() {
        self.textBarContainer.isHidden = true
        self.textBarTextView.delegate = self
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGesture(_:)))
        tapGR.delegate = self
        // Add gesture to edits overlay view since ui overlay view passes through taps
        self.editsOverlayView.addGestureRecognizer(tapGR)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        self.textBarContainer.addGestureRecognizer(panGR)
    }
    
    private func setupPickerView() {
        self.timePickerView.dataSource = self
        self.timePickerView.delegate = self
        self.timePickerContainer.isHidden = true
        
        self.picDisplayTime = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastDisplayTime) as? Int ?? Constants.PicDisplay.defaultDisplayTime
    }
    
    public func drawEditsOnCapturedImage() -> UIImage? {
        guard let capturedImage = self.capturedImage else { return nil }
        
        let layer = self.editsOverlayView.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        capturedImage.draw(in: layer.frame)
        
        layer.render(in: context)
        let editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return editedImage
    }
    
    @IBAction func saveButtonTapped(_ sender: QPButton) {
        self.saveImageToCameraRoll()
    }
    
    public func saveImageToCameraRoll() {
        guard let editedImage = self.drawEditsOnCapturedImage() else {
            self.showGenericErrorAlert(withMessage: UserFacingStrings.Errors.couldNotSaveImage)
            return
        }
        self.saveButton.becomeSpinner()
        UIImageWriteToSavedPhotosAlbum(editedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
        }
        
        self.saveButton.endSpinner()
    }
    
    @IBAction func addTextButtonTapped(_ sender: QPButton) {
        if self.textBarContainer.isHidden {
            self.showTextBar()
        } else if !self.textBarTextView.isFirstResponder {
            self.textBarTextView.selectedRange = NSMakeRange(self.textBarTextView.text.count, 0)
            self.textBarTextView.becomeFirstResponder()
        } else {
            self.stopEditingTextBarAndHideIfEmpty()
        }
    }
    
    /** Shows the text bar and make it the first responder.
 
    - Parameters:
        - height: The distance that should separate the top of the screen from the top of the text bar.
          If none provided, it will show in the middle of the screen.
     */
    public func showTextBar(atHeight height: CGFloat? = nil) {
        let barHeight = height ?? (self.view.frame.height / 2 - self.textBarContainer.frame.height / 2)
        self.setTextBarPosition(to: barHeight)
        self.textBarContainer.isHidden = false
        self.textBarTextView.becomeFirstResponder()
    }
    
    public func stopEditingTextBarAndHideIfEmpty() {
        self.textBarTextView.resignFirstResponder()
        if self.textBarTextView.text.count == 0 {
            self.textBarContainer.isHidden = true
        }
    }
    
    // Using explicit setter for expressiveness
    /// Constrains the text bar so that it will remain fully visible on-screen
    public func setTextBarPosition(to newPosition: CGFloat) {
        self.textBarPosition = min(max(0, newPosition), self.editsOverlayView.frame.height - self.textBarContainer.frame.height)
        self.textBarTopConstraint.constant = self.textBarPosition
    }
    
    @IBAction func timerButtonTapped(_ sender: QPButton) {
        if let row = Constants.PicDisplay.possibleDisplayValues.index(of: self.picDisplayTime) {
            self.timePickerView.selectRow(row, inComponent: 0, animated: false)
        }
        
        self.timePickerContainer.isHidden = false
    }
    
    @IBAction func pickerViewDoneTapped(_ sender: UIButton) {
        self.timePickerContainer.isHidden = true
        
        UserDefaults.standard.set(self.picDisplayTime, forKey: UserDefaultsKeys.lastDisplayTime)
    }
    
    
    @IBAction func exitButtonTapped(_ sender: QPButton) {
        self.delegate?.editPageWillDismiss()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: QPButton) {
        // TODO: Implement
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        self.textBarTopConstraint.isActive = false
        self.textBarBottomConstraint.isActive = true
        self.textBarBottomConstraint.constant = self.view.safeAreaInsets.bottom + keyboardFrame.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.textBarBottomConstraint.isActive = false
        self.textBarTopConstraint.isActive = true
    }
}

extension EditPicViewController : UIGestureRecognizerDelegate {
    @objc func handleSingleTapGesture(_ gesture: UITapGestureRecognizer) {
        if self.textBarContainer.isHidden {
            // Add the text bar at the same vertical location that was tapped
            self.showTextBar(atHeight: gesture.location(in: self.editsOverlayView).y)
        } else {
            self.stopEditingTextBarAndHideIfEmpty()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard self.textBarContainer == gesture.view,
            !self.textBarContainer.isHidden,
            !self.textBarTextView.isFirstResponder else { return }
        
        let translation = gesture.translation(in: self.editsOverlayView).y
        
        switch gesture.state {
        case .began:
            self.textBarInitialPositionForGesture = self.textBarPosition
        case .changed:
            // Track changes for this continuous gesture
            self.setTextBarPosition(to: self.textBarInitialPositionForGesture + translation)
        default:
            break
        }
    }
}

extension EditPicViewController : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.textBarTextView,
            text == "\n" {
            self.stopEditingTextBarAndHideIfEmpty()
            return false
        }
        return true
    }
}

extension EditPicViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.PicDisplay.possibleDisplayValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        guard row >= 0 && row < Constants.PicDisplay.possibleDisplayValues.count else { return UIView() }
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.textAlignment = NSTextAlignment.center
        
        let pickerTitle = NSMutableAttributedString(string: String(Constants.PicDisplay.possibleDisplayValues[row]), attributes: [.font: UIFont.systemFont(ofSize: Constants.PicDisplay.pickerFontSize, weight: .semibold)])
        
        let secondStr = row > 0 ? " seconds" : " second"
        
        pickerTitle.append(NSAttributedString(string: secondStr, attributes: [.font: UIFont.systemFont(ofSize: Constants.PicDisplay.pickerFontSize, weight: .regular)]))
        
        pickerLabel.attributedText = pickerTitle
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.picDisplayTime = Constants.PicDisplay.possibleDisplayValues[row]
    }
}
