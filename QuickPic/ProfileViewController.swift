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

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try FUIAuth.defaultAuthUI()?.signOut()
            self.performSegue(withIdentifier: Ids.Segues.unwindToSignIn, sender: self)
        } catch let error {
            self.showGenericErrorAlert(withMessage: error.localizedDescription)
        }
    }
    
}
