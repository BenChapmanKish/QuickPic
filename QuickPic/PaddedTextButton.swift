//
//  PaddedTextButton.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-28.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

class PaddedTextButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupButton()
    }
    
    private func setupButton() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = Constants.PaddedTextButton.shadowRadius
        self.layer.shadowOpacity = Constants.PaddedTextButton.shadowOpacity
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.cornerRadius = Constants.PaddedTextButton.cornerRadius
        self.contentEdgeInsets = UIEdgeInsets(
            top: Constants.PaddedTextButton.edgeInset,
            left: Constants.PaddedTextButton.edgeInset,
            bottom: Constants.PaddedTextButton.edgeInset,
            right: Constants.PaddedTextButton.edgeInset)
    }

}
