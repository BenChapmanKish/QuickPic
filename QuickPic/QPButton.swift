//
//  QPButton.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-24.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

// TODO: Refactor this class so we don't have to grab/create constraints like this (so ugly)

fileprivate let minimumHitArea = CGSize(width: 50, height: 50)

class QPButton: UIButton {
    
    private var widthConstraint: NSLayoutConstraint!
    private var normalImage: UIImage?
    
    private var normalSize: CGFloat = Constants.QPButton.defaultNormalSize
    private var highlightedSizeIncrease: CGFloat = Constants.QPButton.defaultHighlightedSizeIncrease
    
    private static var spinAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.fromValue = 0.0
        animation.toValue = CGFloat.pi * 2
        animation.duration = Constants.QPButton.spinAnimationDuration
        animation.repeatCount = .infinity
        
        return animation
    }()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.normalImage = self.image(for: .normal)
        self.setupShadow()
        self.setupEnlargeOnHighlighted()
    }
    
    private func setupShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = Constants.QPButton.shadowRadius
        self.layer.shadowOpacity = Constants.QPButton.shadowOpacity
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
    }
    
    private func setupEnlargeOnHighlighted() {
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
        self.animateConstraintChange(constant: self.normalSize + self.highlightedSizeIncrease)
    }
    
    @objc func shrinkButton(_ sender: Any?) {
        self.animateConstraintChange(constant: self.normalSize)
    }
    
    private func animateConstraintChange(constant: CGFloat) {
        self.superview?.layoutIfNeeded()
        self.widthConstraint.constant = constant
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.QPButton.growShrinkAnimationDuration,
            delay: 0,
            options: [.curveLinear,
                      .allowUserInteraction],
            animations: {
                self.superview?.layoutIfNeeded()
        })
    }

    
    /// Become an animated loading spinner while an action happens
    public func becomeSpinner() {
        self.isUserInteractionEnabled = false
        self.setImage(#imageLiteral(resourceName: "Spinner"), for: .normal)
        self.layer.add(QPButton.spinAnimation, forKey: nil)
    }
    
    /// Stop being a loading spinner and return to normal
    public func endSpinner() {
        guard let normalImage = self.normalImage else { return }
        self.layer.removeAllAnimations()
        self.setImage(normalImage, for: .normal)
        self.isUserInteractionEnabled = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !self.isHidden, self.isUserInteractionEnabled, self.alpha > 0 else { return nil }
        
        let extraWidth = max(0, minimumHitArea.width - self.bounds.size.width)
        let extraHeight = max(0, minimumHitArea.height - self.bounds.size.height)
        let largerFrame = self.bounds.insetBy(dx: -extraWidth / 2, dy: -extraHeight / 2)
        
        return largerFrame.contains(point) ? self : nil
    }
}
