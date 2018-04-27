//
//  UIView+Helpers.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-23.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

extension UIView {
    func constrainToSuperview(withConstant constant: CGFloat = 0.0) {
        guard let superview = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: constant),
            self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -1 * constant),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: constant),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -1 * constant)
            ])
    }
}
