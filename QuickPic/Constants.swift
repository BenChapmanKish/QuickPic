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
    }
}

struct UserFacingStrings {
    struct Errors {
        static let genericErrorTitle = "An error happened"
        static let couldNotSaveImage = "We couldn't save the image to your camera roll!"
        static let couldNotOpenLoginFlow = "We couldn't open the sign in screen!"
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
}
