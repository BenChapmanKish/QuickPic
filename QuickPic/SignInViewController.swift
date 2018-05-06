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

class SignInViewController: UIViewController {

    @IBOutlet var signInButton: UIButton!
    
    private var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        self.authUI?.providers = [FUIGoogleAuth()]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let activityIndicator = self.showActivityIndicator()
        
        QPUser.loginUser(completion: { (error, loginResult) in
            self.hideActivityIndicator(activityIndicator)
            
            if let error = error {
                self.showGenericErrorAlert(withMessage: error.localizedDescription)
                return
            }
            
            switch loginResult {
            case .needMoreInfo:
                self.performSegue(withIdentifier: Ids.Segues.showSignUpMoreInfoVC, sender: self)
            case .success, .alreadyLoggedIn:
                self.performSegue(withIdentifier: Ids.Segues.showCoreVC, sender: self)
            default:
                break
            }
        })
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
        }
    }
}
