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
    }
}

struct UserFacingStrings {
    struct Errors {
        static let genericErrorTitle = "An error happened"
        static let couldNotSaveImage = "We couldn't save the image to your camera roll!"
    }
}
struct UserDefaultsKeys {
    static let lastFlashMode = "lastFlashMode"
}

struct Constants {
    
    struct PicDisplay {
        static let possibleDisplayValues: [Int] = Array(1 ... 10)
        static let defaultDisplayTime: Int = 10
    }
    
    struct QPButton {
        static let defaultNormalSize: CGFloat = 30.0
        static let defaultHighlightedSizeIncrease: CGFloat = 10.0
        static let shadowRadius: CGFloat = 3.0
        static let shadowOpacity: Float = 0.5
        static let spinAnimationDuration: CFTimeInterval = 1.0
    }
}
