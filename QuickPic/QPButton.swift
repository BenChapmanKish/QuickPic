//
//  QPButton.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-24.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

// TODO: Refactor this class so we don't have to grab/create constraints like this (so ugly)

class QPButton: UIButton {
    
    var widthConstraint: NSLayoutConstraint!
    
    var normalSize: CGFloat = 30.0
    var highlightedSizeIncrease: CGFloat = 10.0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Grab an existing width constraint, or create one if needed
        if let widthConstraint = self.constraints.first(where: {
            return $0.firstItem as? QPButton == self
                && $0.firstAttribute == .width
                && $0.constant > 0
                && $0.secondItem == nil
        }) {
            self.widthConstraint = widthConstraint
            self.normalSize = widthConstraint.constant
        } else {
            self.widthConstraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: self.normalSize)
        }
        
        self.widthConstraint.isActive = true
        
        // Create an aspect ratio constraint if necessary
        if self.constraints.first(where: {
            return $0.firstItem as? QPButton == self
                && $0.firstAttribute == .width
                && $0.secondItem as? QPButton == self
                && $0.secondAttribute == .height
        }) == nil {
            NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        }
        
        // Add handlers for adjusting button size when highlighted
        self.addTarget(self, action: #selector(expandButton(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(expandButton(_:)), for: .touchDragEnter)
        
        self.addTarget(self, action: #selector(shrinkButton(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(shrinkButton(_:)), for: .touchDragExit)
        self.addTarget(self, action: #selector(shrinkButton(_:)), for: .touchCancel)
    }
    
    @objc func expandButton(_ sender: Any?) {
        self.widthConstraint.constant = self.normalSize + self.highlightedSizeIncrease
    }
    
    @objc func shrinkButton(_ sender: Any?) {
        self.widthConstraint.constant = self.normalSize
    }

}
