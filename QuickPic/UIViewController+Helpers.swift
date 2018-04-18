//
//  UIViewController+Helpers.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertWithOkButton(title: String = "Oh no!", message: String? = nil, okAction: (() -> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            okAction?()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
}
