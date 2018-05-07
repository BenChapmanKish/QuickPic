//
//  Constants.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-23.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import Foundation
import UIKit

struct Ids {
    struct Identifiers {
        static let mainStoryboard = "Main"
        static let inboxVC = "InboxViewController"
        static let cameraVC = "CameraViewController"
        static let profileVC = "ProfileViewController"
    }
    
    struct Segues {
        static let showEditPicVC = "showEditPicVC"
        static let showCoreVC = "showCoreVC"
        static let unwindToSignIn = "unwindToSignIn"
        static let showSignUpMoreInfoVC = "showSignUpMoreInfoVC"
    }
    
    struct DatabaseKeys {
        static let usersCollection = "users"
        static let picsCollection = "pics"
        
        static let uidKey = "uid"
        static let usernameKey = "username"
        static let birthdayKey = "birthday"
        static let displayNameKey = "displayName"
        static let picsSentKey = "totalPicsSent"
        static let picsReceivedKey = "totalPicsReceived"
        static let friendsListKey = "listOfFriendUIDs"
    }
}

struct UserFacingStrings {
    struct Errors {
        static let genericErrorTitle = "An error happened"
        static let couldNotSaveImage = "We couldn't save the image to your camera roll!"
        static let couldNotOpenLoginFlow = "We couldn't open the sign in screen!"
        static let couldNotRetrieveUserData = "We couldn't retrieve your data from the server!"
        static let problemPerformingOperation = "There was a problem performing that operation!"
        static let couldNotCreateAccount = "We couldn't create your account!"
        static let invalidUsername = "That username is invalid. Please try a different one."
        static let usernameTaken = "That username is already taken. Please try a different one."
    }
    
    struct Friends {
        static let enterFriendMessage = "Enter the username of the friend you want to add."
        static let cannotAddSelf = "You can't add yourself as a friend!"
        static let alreadyIsFriend = " is already in your friends list!"
        static let friendAdded = " has been added to your friends!"
        static let noUserFound = "We couldn't find anyone with that username!"
    }
}
struct UserDefaultsKeys {
    static let lastFlashMode = "lastFlashMode"
    static let lastDisplayTime = "lastDisplayTime"
}

struct Constants {
    struct Camera {
        static let pinchVelocityDivisionFactor: CGFloat = 40.0
        static let maxZoomFactor: CGFloat = 10.0
    }
    
    struct TextBar {
        static let backgroundColor = UIColor(white: 0.0, alpha: 0.8)
        static let fontSize: CGFloat = 16.0
        static let textInset: CGFloat = 3.0
        static let animationDuration: TimeInterval = 0.15
    }
    
    struct PicDisplay {
        static let possibleDisplayValues: [Int] = Array(1 ... 10)
        static let defaultDisplayTime: Int = 10
        static let pickerFontSize: CGFloat = 22.0
    }
    
    struct IconButton {
        static let defaultNormalSize: CGFloat = 30.0
        static let defaultHighlightedSizeIncrease: CGFloat = 10.0
        static let shadowRadius: CGFloat = 3.0
        static let shadowOpacity: Float = 0.5
        static let spinAnimationDuration: CFTimeInterval = 1.0
        static let growShrinkAnimationDuration: TimeInterval = 0.1
    }
    
    struct PaddedTextButton {
        static let cornerRadius: CGFloat = 5.0
        static let shadowRadius: CGFloat = 3.0
        static let shadowOpacity: Float = 0.5
        static let edgeInset: CGFloat = 12.0
    }
}
