//
//  SignInViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-27.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

import FirebaseAuthUI
import FirebaseGoogleAuthUI

// This entire page is a WIP, both in code and appearance

class SignInViewController: UIViewController {

    @IBOutlet var signInButton: UIButton!
    
    private var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        self.authUI?.providers = [FUIGoogleAuth()]
        
        self.configureSignInButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: Ids.Segues.showCoreVC, sender: self)
        }
    }
    
    private func configureSignInButton() {
        self.signInButton.layer.cornerRadius = 5.0
        self.signInButton.layer.shadowColor = UIColor.black.cgColor
        self.signInButton.layer.shadowOpacity = 0.5
        self.signInButton.layer.shadowRadius = 5.0
        self.signInButton.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let authVC = self.authUI?.authViewController() else {
            self.showGenericErrorAlert(withMessage: UserFacingStrings.Errors.couldNotOpenLoginFlow)
            return
        }
        self.present(authVC, animated: true)
    }
    
    @IBAction func unwindToSignIn(segue: UIStoryboardSegue) {
        // No-op
    }
}

extension SignInViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            if !(error._domain == FUIAuthErrorDomain && error._code == FUIAuthErrorCode.userCancelledSignIn.rawValue) {
                self.showGenericErrorAlert(withMessage: error.localizedDescription)
            }
            return
        }
        
        self.performSegue(withIdentifier: Ids.Segues.showCoreVC, sender: self)
    }
}
