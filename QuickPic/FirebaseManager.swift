//
//  FirebaseManager.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-05-03.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit
import Firebase

class UserData {
    var uid: String
    var displayName: String
    var totalPicsSent: Int
    var totalPicsReceived: Int
    var friends: [String] // UIDs of friends
    
    init(uid: String, displayName: String?, totalPicsSent: Int = 0, totalPicsReceived: Int = 0, friends: [String] = []) {
        self.uid = uid
        self.displayName = displayName ?? uid
        self.totalPicsSent = totalPicsSent
        self.totalPicsReceived = totalPicsReceived
        self.friends = friends
    }
    
    convenience init?(uid: String, fromDictionary dictionary: [String : Any]) {
        guard let displayName = dictionary[Ids.DatabaseKeys.displayNameKey] as? String,
            let picsSent = dictionary[Ids.DatabaseKeys.picsSentKey] as? Int,
            let picsReceived = dictionary[Ids.DatabaseKeys.picsReceivedKey] as? Int,
            let friends = dictionary[Ids.DatabaseKeys.friendsListKey] as? [String] else {
                return nil
        }
        
        self.init(uid: uid, displayName: displayName, totalPicsSent: picsSent, totalPicsReceived: picsReceived, friends: friends)
    }
    
    public func changeDisplayName(to newName: String, completion: ((Error?) -> Void)? = nil) {
        FirebaseManager.changeUser(uid: self.uid, displayNameTo: newName) { error in
            self.displayName = newName
            completion?(error)
        }
    }
}

class FirebaseManager {
    private static var db: Firestore = {
        return Firestore.firestore()
    }()
    
    private static var usersCollection: CollectionReference = {
        return FirebaseManager.db.collection(Ids.DatabaseKeys.usersCollection)
    }()
    
    public static func createUser(fromFirebaseUser firebaseUser: User, completion: @escaping (Error?, UserData) -> Void) {
        let userData = UserData(uid: firebaseUser.uid, displayName: firebaseUser.displayName)
        
        var canContinueWithCreatingUser = true
        
        self.usersCollection.document(userData.uid).getDocument { (snapshot, error) in
            if error != nil {
                completion(error, userData)
                canContinueWithCreatingUser = false
            } else if snapshot != nil {
                let error = NSError(domain: "FirebaseManager", code: 1, userInfo: [NSLocalizedDescriptionKey: UserFacingStrings.Errors.couldNotCreateAccount])
                completion(error, userData)
                canContinueWithCreatingUser = false
            }
        }
        
        guard canContinueWithCreatingUser else { return }
        
        self.usersCollection.document(userData.uid).setData([
            Ids.DatabaseKeys.displayNameKey : userData.displayName,
            Ids.DatabaseKeys.picsSentKey : userData.totalPicsSent,
            Ids.DatabaseKeys.picsReceivedKey : userData.totalPicsReceived,
            Ids.DatabaseKeys.friendsListKey : userData.friends
        ], completion: { error in
            completion(error, userData)
        })
    }
    
    public static func lookupUser(uid: String, completion: @escaping ((Error?, UserData?) -> Void)) {
        var userData: UserData?
        
        self.usersCollection.document(uid).getDocument { (snapshot, error) in
            if let data = snapshot?.data() {
                userData = UserData(uid: uid, fromDictionary: data)
            }
            
            completion(error, userData)
        }
    }
    
    public static func changeUser(uid: String, displayNameTo newName: String, completion: ((Error?) -> Void)?) {
        self.usersCollection.document(uid).updateData([
            Ids.DatabaseKeys.displayNameKey : newName
        ]) { error in
            completion?(error)
        }
    }
}
