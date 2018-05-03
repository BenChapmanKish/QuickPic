//
//  UIViewController+Helpers.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-17.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertWithOkButton(title: String? = nil, message: String? = nil, okAction: (() -> Void)? = nil ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            okAction?()
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    func showGenericErrorAlert(withMessage message: String? = nil) {
        self.showAlertWithOkButton(title: UserFacingStrings.Errors.genericErrorTitle, message: message)
    }
    
    func showActivityIndicator() -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(frame: self.view.bounds)
        
        indicatorView.center = self.view.center
        
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.startAnimating()
        
        DispatchQueue.main.async {
            self.view.addSubview(indicatorView)
        }
        
        return indicatorView
    }
    
    func hideActivityIndicator(_ indicatorView: UIActivityIndicatorView) {
        indicatorView.removeFromSuperview()
    }
}
