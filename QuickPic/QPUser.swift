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
    
    private static func createNewUserIfPossible() throws {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else { return }
        
        do {
            let userData = try FirebaseManager.createUser(fromFirebaseUser: firebaseUser)
            self.loggedInUser = QPLoginUser(firebaseUser: firebaseUser, userData: userData)
        } catch {
            throw error
        }
    }
    
    public static func loginUserIfPossible() throws {
        guard let firebaseUser = Auth.auth().currentUser,
            self.loggedInUser == nil else { return }
        
        var requestError: Error?
        
        FirebaseManager.lookupUser(uid: firebaseUser.uid) { (error, userData) in
            if error != nil {
                requestError = error
                return
            }
            
            if let userData = userData {
                self.loggedInUser = QPLoginUser(firebaseUser: firebaseUser, userData: userData)
            } else {
                do {
                    try self.createNewUserIfPossible()
                } catch {
                    requestError = error
                }
            }
        }
        
        if let error = requestError {
            throw error
        }
    }
    
    public static func logout() throws {
        try FUIAuth.defaultAuthUI()?.signOut()
        self.loggedInUser = nil
    }
    
    
    
    private var firebaseUser: User
    
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
    
    public func getFriends(completion: @escaping ([QPUser]) -> Void) {
        var friends = [QPUser]()
        var friendsFetched = 0
        
        self.userData.friends.forEach { uid in
            QPUser.lookupUser(uid: uid, completion: { user in
                friendsFetched += 1
                
                if let user = user {
                    friends.append(user)
                }
                
                if friendsFetched == friends.count {
                    completion(friends)
                }
            })
        }
    }
}
