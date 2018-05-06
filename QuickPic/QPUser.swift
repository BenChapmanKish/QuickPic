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

enum LoginResult {
    case error
    case noLoginYet
    case needMoreInfo
    case success
    case alreadyLoggedIn
}

class QPUser {
    public static var loggedInUser: QPUser?
    
    public static func createNewUser(withUsername username: String, birthday: Date, completion: @escaping (Error?) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else {
                let error = NSError(domain: "QPUser", code: 2, userInfo: [NSLocalizedDescriptionKey : UserFacingStrings.Errors.couldNotCreateAccount])
                completion(error)
                return
        }
        
        FirebaseManager.createUser(fromFirebaseUser: firebaseUser, username: username, birthday: birthday) { error, userData in
            guard error == nil else {
                completion(error)
                return
            }
            
            self.loggedInUser = QPUser(firebaseUser: firebaseUser, userData: userData)
            completion(nil)
        }
    }
    
    public static func loginUser(completion: @escaping (Error?, LoginResult) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else {
            completion(nil, .noLoginYet)
            return
        }
        guard self.loggedInUser == nil else {
            completion(nil, .alreadyLoggedIn)
            return
        }
        
        FirebaseManager.lookupUser(uid: firebaseUser.uid) { (error, userData) in
            guard error == nil else {
                completion(error, .error)
                return
            }
            
            if let userData = userData {
                self.loggedInUser = QPUser(firebaseUser: firebaseUser, userData: userData)
                completion(nil, .success)
            } else {
                completion(nil, .needMoreInfo)
            }
        }
    }
    
    public static func logout() throws {
        try FUIAuth.defaultAuthUI()?.signOut()
        self.loggedInUser = nil
    }
    
    
    
    private var firebaseUser: User
    private(set) var userData: UserData
    private var friends: [String : UserData] = [:]
    
    init(firebaseUser: User, userData: UserData) {
        self.firebaseUser = firebaseUser
        self.userData = userData
        
        self.updateFriends()
    }
    
    public func changeDisplayName(to newName: String, callback: UserProfileChangeCallback? = nil) {
        let changeRequest = self.firebaseUser.createProfileChangeRequest()
        changeRequest.displayName = newName
        changeRequest.commitChanges { error in
            if error == nil {
                self.userData.changeDisplayName(to: newName, completion: { error in
                    callback?(error)
                })
            } else {
                callback?(error)
            }
        }
    }
    
    public func updateFriends() {
        self.userData.friends.forEach { uid in
            FirebaseManager.lookupUser(uid: uid, completion: { (error, user) in
                if let user = user {
                    self.friends[uid] = user
                }
            })
        }
    }
}
