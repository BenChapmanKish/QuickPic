//
//  QPUser.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-28.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI

class QPUser {
    
    public static var loggedInUser: QPUser?
    
    public static func loginFromFirebaseUserIfPossible() {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else { return }
        
        self.loggedInUser = QPUser(firebaseUser: firebaseUser)
    }
    
    public static func logout() throws {
        try FUIAuth.defaultAuthUI()?.signOut()
        self.loggedInUser = nil
    }
    
    
    private var firebaseUser: User!
    
    private var _totalPicsSent: UInt = 0
    private var _totalPicsReceived: UInt = 0
    
    init(firebaseUser: User) {
        self.firebaseUser = firebaseUser
    }
    
    public func changeUserName(to newName: String, callback: UserProfileChangeCallback? = nil) {
        let changeRequest = self.firebaseUser.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges(completion: callback)
    }
    
    
    public var name: String {
        return self.firebaseUser.displayName ?? self.firebaseUser.uid
    }
    
    public var totalPicsSent: Int {
        return Int(self._totalPicsSent)
    }
    
    public var totalPicsReceived: Int {
        return Int(self._totalPicsReceived)
    }
}
