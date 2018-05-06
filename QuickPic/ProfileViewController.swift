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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try QPUser.logout()
            self.performSegue(withIdentifier: Ids.Segues.unwindToSignIn, sender: self)
        } catch {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
        }
    }
    
}
