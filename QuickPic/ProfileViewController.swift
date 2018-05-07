//
//  ProfileViewController.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-28.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class ProfileViewController: UIViewController {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = QPUser.loggedInUser else { return }
        
        self.usernameLabel.text = user.userData.username
        self.nameLabel.text = user.userData.displayName
        self.statsLabel.text = "Sent: \(user.userData.totalPicsSent) | Received: \(user.userData.totalPicsReceived)"

        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func changeNameButtonTapped(_ sender: UIButton) {
        self.showChangeNameAlert()
    }
    
    private func showChangeNameAlert() {
        guard let user = QPUser.loggedInUser else { return }
        
        let alert = UIAlertController(title: "Enter name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Display name"
            textField.text = user.userData.displayName
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        
        let doneAction = UIAlertAction(
            title: "Done",
            style: .default,
            handler: { action in
                guard let newName = alert.textFields?[0].text else { return }
                
                self.attemptToChangeName(to: newName)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        self.present(alert, animated: true)
    }
    
    private func attemptToChangeName(to newName: String) {
        let activityIndicator = self.showActivityIndicator()
        
        QPUser.loggedInUser?.changeDisplayName(
            to: newName,
            callback: { error in
                self.hideActivityIndicator(activityIndicator)
                
                if let error = error {
                    self.showGenericErrorAlert(withMessage: error.localizedDescription)
                    return
                }
                
                self.nameLabel.text = newName
        })
    }
    
    @IBAction func addFriendsButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Friend", message: UserFacingStrings.Friends.enterFriendMessage, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Username"
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        
        let addAction = UIAlertAction(
            title: "Add",
            style: .default,
            handler: { action in
                guard let username = alert.textFields?[0].text else { return }
                self.addFriend(withUsername: username)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true)
    }
    
    private func addFriend(withUsername username: String) {
        guard let user = QPUser.loggedInUser else { return }
        
        let activityIndicator = self.showActivityIndicator()
        
        user.addFriend(withUsername: username) { (error, resultMessage) in
            self.hideActivityIndicator(activityIndicator)
            
            if let error = error {
                self.showGenericErrorAlert(withMessage: error.localizedDescription)
            } else if let message = resultMessage {
                self.showAlertWithOkButton(message: message)
            }
        }
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try QPUser.logout()
            self.performSegue(withIdentifier: Ids.Segues.unwindToSignIn, sender: self)
        } catch {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
        }
    }
    
}
