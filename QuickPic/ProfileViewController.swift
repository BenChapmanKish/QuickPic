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
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = QPUser.loggedInUser else { return }
        
        self.nameLabel.text = user.name
        self.statsLabel.text = "Sent: \(user.totalPicsSent) | Received: \(user.totalPicsReceived)"

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
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        self.showEditAlert()
    }
    
    private func showEditAlert() {
        guard let user = QPUser.loggedInUser else { return }
        
        let alert = UIAlertController(title: "Enter name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Display name"
            textField.text = user.name
        }
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)
        
        let doneAction = UIAlertAction(
            title: "Done",
            style: .default,
            handler: { action in
                guard let newName = alert.textFields?[0].text else { return }
                
                self.attemptToChangeUserName(to: newName)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(doneAction)
        self.present(alert, animated: true)
    }
    
    private func attemptToChangeUserName(to newName: String) {
        let activityIndicator = self.showActivityIndicator()
        
        QPUser.loggedInUser?.changeUserName(
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
        } catch let error {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
        }
    }
    
}
