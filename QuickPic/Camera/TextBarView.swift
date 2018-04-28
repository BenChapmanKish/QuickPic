//
//  TextBarView.swift
//  QuickPic
//
//  Created by Ben Chapman-Kish on 2018-04-25.
//  Copyright © 2018 Ben Chapman-Kish. All rights reserved.
//

import UIKit

protocol TextBarViewDelegate {
    func textBarViewMayBeDragged() -> Bool
    func textBarViewDidBeginEditing(_ textView: TextBarView)
}

class TextBarView: UIView {
    
    private var topConstraint: NSLayoutConstraint!
    private var textView = UITextView(frame: .zero)
    
    private var initialPositionForGesture: CGFloat = 0.0
    private var position: CGFloat = 0.0
    
    private var delegate: TextBarViewDelegate?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(inView superview: UIView, atPosition position: CGFloat? = nil, delegate: TextBarViewDelegate? = nil) {
        super.init(frame: .zero)
        
        self.setupConstraints(withSuperview: superview)
        self.setupViews()
        
        self.layoutIfNeeded()
        
        let barPosition = position ?? superview.frame.height/2 - self.frame.height/2
        self.setPosition(to: barPosition)
        
        self.setupPanGesture()
        
        self.delegate = delegate
    }
    
    private func setupConstraints(withSuperview superview: UIView) {
        superview.addSubview(self)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: superview.leftAnchor),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor),
            ])
        
        self.topConstraint = NSLayoutConstraint(
            item: self,
            attribute: .top,
            relatedBy: .equal,
            toItem: superview,
            attribute: .top,
            multiplier: 1.0,
            constant: 0.0)
        self.topConstraint.isActive = true
        
        self.addSubview(self.textView)
        self.textView.constrainToSuperview(withConstant: Constants.TextBar.textInset)
        self.textView.delegate = self
    }
    
    private func setupViews() {
        self.backgroundColor = Constants.TextBar.backgroundColor
        
        self.textView.font = UIFont.systemFont(ofSize: Constants.TextBar.fontSize)
        self.textView.textColor = .white
        self.textView.backgroundColor = .clear
        self.textView.textAlignment = .center
        self.textView.returnKeyType = .done
        
        self.textView.isEditable = true
        self.textView.isSelectable = true
        
        self.textView.isScrollEnabled = false
        self.textView.showsHorizontalScrollIndicator = false
        self.textView.showsVerticalScrollIndicator = false
        self.textView.bounces = false
        self.textView.bouncesZoom = false
    }

    private func setupPanGesture() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panGR)
    }
    
    /// Constrains the text bar so that it will remain fully visible on-screen
    private func setPosition(to newPosition: CGFloat) {
        guard let superview = self.superview else { return }
        self.position = min(max(0, newPosition), superview.frame.height - self.frame.height)
        self.topConstraint.constant = self.position
    }
    
    public func beginEditing() {
        self.textView.becomeFirstResponder()
    }
    
    public func switchToBottomConstraint(withConstant bottomConstant: CGFloat) {
        guard let superview = self.superview else { return }
        var topConstant = superview.frame.height - self.frame.height - bottomConstant
        topConstant = min(max(0, topConstant), superview.frame.height - self.frame.height)
        self.animateConstraintChange(constant: topConstant)
    }
    
    public func switchToTopConstraint() {
        self.animateConstraintChange(constant: self.position)
    }
    
    private func animateConstraintChange(constant: CGFloat) {
        self.superview?.layoutIfNeeded()
        self.topConstraint.constant = constant
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: Constants.TextBar.animationDuration,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                self.superview?.layoutIfNeeded()
        })
    }
    
    public func stopEditing() {
        self.textView.resignFirstResponder()
    }
    
    private func removeSelfIfEmpty() {
        if self.textView.text.isEmpty {
            self.removeFromSuperview()
        } else {
            self.switchToTopConstraint()
        }
    }
}

extension TextBarView : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.delegate?.textBarViewDidBeginEditing(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == self.textView,
            text == "\n" {
            self.stopEditing()
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.removeSelfIfEmpty()
    }
}

extension TextBarView : UIGestureRecognizerDelegate {
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        if let delegate = self.delegate,
            !delegate.textBarViewMayBeDragged() {
            return
        }
        
        let translation = gesture.translation(in: superview).y
        
        switch gesture.state {
        case .began:
            self.initialPositionForGesture = self.position
        case .changed:
            // Track changes for this continuous gesture
            self.setPosition(to: self.initialPositionForGesture + translation)
        default:
            break
        }
    }
}
