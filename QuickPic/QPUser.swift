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
    fileprivate var userData: UserData
    
    init(userData: UserData) {
        self.userData = userData
    }
    
    public static func lookupUser(uid: String, completion: @escaping (QPUser?) -> Void) {
        FirebaseManager.lookupUser(uid: uid) { (error, userData) in
            guard error == nil,
                let userData = userData else {
                completion(nil)
                return
            }
            completion(QPUser(userData: userData))
        }
    }
    
    
    public var name: String {
        return self.userData.displayName
    }
    
    public var totalPicsSent: Int {
        return self.userData.totalPicsSent
    }
    
    public var totalPicsReceived: Int {
        return self.userData.totalPicsReceived
    }
}

class QPLoginUser: QPUser {
    public static var loggedInUser: QPLoginUser?
    
    private static func createNewUserIfPossible(completion: @escaping (Error?) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else {
                let error = NSError(domain: "QPUser", code: 2, userInfo: [NSLocalizedDescriptionKey : UserFacingStrings.Errors.couldNotCreateAccount])
                completion(error)
                return
        }
        
        FirebaseManager.createUser(fromFirebaseUser: firebaseUser) { error, userData in
            guard error == nil else {
                completion(error)
                return
            }
            
            self.loggedInUser = QPLoginUser(firebaseUser: firebaseUser, userData: userData)
            completion(nil)
        }
    }
    
    public static func loginUser(completion: @escaping (Error?, QPLoginUser?) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else {
                completion(nil, nil)
                return
        }
        
        FirebaseManager.lookupUser(uid: firebaseUser.uid) { (error, userData) in
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            if let userData = userData {
                self.loggedInUser = QPLoginUser(firebaseUser: firebaseUser, userData: userData)
                completion(nil, self.loggedInUser)
            } else {
                self.createNewUserIfPossible(completion: { error in
                    guard error == nil else {
                        completion(error, nil)
                        return
                    }
                    
                    completion(nil, self.loggedInUser)
                })
            }
        }
    }
    
    public static func logout() throws {
        try FUIAuth.defaultAuthUI()?.signOut()
        self.loggedInUser = nil
    }
    
    
    
    private var firebaseUser: User
    private var friends: [String : QPUser] = [:]
    
    init(firebaseUser: User, userData: UserData) {
        self.firebaseUser = firebaseUser
        super.init(userData: userData)
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
            QPUser.lookupUser(uid: uid, completion: { user in
                if let user = user {
                    self.friends[uid] = user
                }
            })
        }
    }
}
