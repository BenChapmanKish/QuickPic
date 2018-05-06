//
//  SignUpMoreInfoViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-05-06.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

fileprivate let defaultBirthdayYearsAgo = 20

class SignUpMoreInfoViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var birthdayButton: UIButton!
    @IBOutlet var birthdayPicker: UIDatePicker!
    
    @IBOutlet var birthdayPickerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        
        self.birthdayPicker.maximumDate = Date()
        
        let selectedDate = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .year, value: -defaultBirthdayYearsAgo, to: Date()) ?? Date()
        )
        
        self.birthdayPicker.date = selectedDate
        self.setBirthdayLabel(to: selectedDate)
        
        self.birthdayButton.layer.cornerRadius = 5.0
        self.birthdayButton.layer.borderWidth = 0.5
        self.birthdayButton.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }

    
    @IBAction func birthdaySelectButtonTapped(_ sender: UIButton) {
        self.usernameField.resignFirstResponder()
        self.birthdayPickerContainer.isHidden = false
    }
    
    @IBAction func birthdayDoneButtonTapped(_ sender: UIButton) {
        self.birthdayPickerContainer.isHidden = true
    }
    
    @IBAction func birthdayValueChanged(_ sender: UIDatePicker) {
        self.setBirthdayLabel(to: sender.date)
    }
    
    private func setBirthdayLabel(to birthday: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
        let description = dateFormatter.string(from: birthday)
        self.birthdayButton.setTitle(description, for: .normal)
    }
    
    
    @IBAction func signUpButtonTapped(_ sender: PaddedTextButton) {
        let activityIndicator = self.showActivityIndicator()
        
        self.validateInput(completion: { (error, username, birthday) in
            if let error = error {
                self.hideActivityIndicator(activityIndicator)
                
                self.showGenericErrorAlert(withMessage: error.localizedDescription)
                return
            }
            
            QPUser.createNewUser(withUsername: username, birthday: birthday, completion: { (error) in
                self.hideActivityIndicator(activityIndicator)
                
                if let error = error {
                    self.showGenericErrorAlert(withMessage: error.localizedDescription)
                    return
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    private func validateInput(completion: @escaping (Error?, String, Date) -> Void) {
        guard let username = self.usernameField.text,
            !username.isEmpty else {
            self.usernameField.backgroundColor = #colorLiteral(red: 1, green: 0.6882307529, blue: 0.6809231043, alpha: 1)
            let error = NSError(domain: "NewUserValidation", code: 1, userInfo: [NSLocalizedDescriptionKey : UserFacingStrings.Errors.invalidUsername])
            completion(error, "", Date())
            return
        }
        
        let birthday = self.birthdayPicker.date
        
        FirebaseManager.checkIfUsernameIsAvailable(username: username) { (error, available) in
            if let error = error {
                completion(error, username, birthday)
            } else if !available {
                let error = NSError(domain: "NewUserValidation", code: 1, userInfo: [NSLocalizedDescriptionKey : UserFacingStrings.Errors.usernameTaken])
                completion(error, username, birthday)
            } else {
                completion(nil, username, birthday)
            }
        }
    }

}

extension SignUpMoreInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.birthdayPickerContainer.isHidden = false
        return false
    }
}
