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
    var username: String
    var birthday: Date
    var displayName: String
    var totalPicsSent: Int
    var totalPicsReceived: Int
    var friends: [String] // UIDs of friends
    
    init(uid: String, username: String, birthday: Date, displayName: String, totalPicsSent: Int = 0, totalPicsReceived: Int = 0, friends: [String] = []) {
        self.uid = uid
        self.username = username
        self.birthday = birthday
        self.displayName = displayName
        self.totalPicsSent = totalPicsSent
        self.totalPicsReceived = totalPicsReceived
        self.friends = friends
    }
    
    convenience init?(uid: String, fromDictionary dictionary: [String : Any]) {
        guard let username = dictionary[Ids.DatabaseKeys.usernameKey] as? String,
            let birthday = dictionary[Ids.DatabaseKeys.birthdayKey] as? Date,
            let displayName = dictionary[Ids.DatabaseKeys.displayNameKey] as? String,
            let picsSent = dictionary[Ids.DatabaseKeys.picsSentKey] as? Int,
            let picsReceived = dictionary[Ids.DatabaseKeys.picsReceivedKey] as? Int,
            let friends = dictionary[Ids.DatabaseKeys.friendsListKey] as? [String] else {
                return nil
        }
        
        self.init(uid: uid, username: username, birthday: birthday, displayName: displayName, totalPicsSent: picsSent, totalPicsReceived: picsReceived, friends: friends)
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
    
    public static func createUser(fromFirebaseUser firebaseUser: User, username: String, birthday: Date, completion: @escaping (Error?, UserData) -> Void) {
        let userData = UserData(uid: firebaseUser.uid, username: username, birthday: birthday, displayName: firebaseUser.displayName ?? username)
        
        self.usersCollection.document(userData.uid).setData([
            Ids.DatabaseKeys.usernameKey : userData.username,
            Ids.DatabaseKeys.birthdayKey : userData.birthday,
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
    
    public static func checkIfUsernameIsAvailable(username: String, completion: @escaping (Error?, Bool) -> Void) {
        // TODO: Implement
        completion(nil, true)
    }
}
