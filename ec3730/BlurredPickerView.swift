//
//  BlurredPickerView.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/27/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class BlurredPickerView: UIView {
    var background: UIVisualEffectView
    var picker: UIPickerView
    var animationDuration: TimeInterval = 0.8

    private var presenting = false
    private var bottomConstraint: NSLayoutConstraint?
    var bottom: NSLayoutYAxisAnchor? {
        didSet {
            guard let bottom = self.bottom else {
                return
            }

            bottomConstraint?.isActive = false
            bottomConstraint = bottomAnchor.constraint(equalTo: bottom, constant: picker.frame.height * 1.5)
            bottomConstraint?.isActive = true
        }
    }

    init(picker: UIPickerView, style: UIBlurEffect.Style) {
        background = UIVisualEffectView(effect: UIBlurEffect(style: style))
        self.picker = picker
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.picker.translatesAutoresizingMaskIntoConstraints = false
        background.translatesAutoresizingMaskIntoConstraints = false

        addSubview(background)
        addSubview(self.picker)

        self.picker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.picker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.picker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.picker.widthAnchor.constraint(equalTo: widthAnchor).isActive = true

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": self.background]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": self.background]))

//        self.background.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
//        self.background.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        self.background.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        self.heightAnchor.constraint(equalTo: self.picker.heightAnchor).isActive = true

        let doneBar = UIToolbar()
        doneBar.isTranslucent = true
        doneBar.isUserInteractionEnabled = true
        doneBar.translatesAutoresizingMaskIntoConstraints = false
        doneBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismiss(_:)))
        ]

        addSubview(doneBar)

        doneBar.bottomAnchor.constraint(equalTo: self.picker.topAnchor).isActive = true
        doneBar.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        doneBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        doneBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        topAnchor.constraint(equalTo: doneBar.topAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func dismiss(_: Any?) {
        layer.removeAllAnimations()
        picker.resignFirstResponder()

        guard let _ = self.bottom else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.isHidden = true
            })
            return
        }

        bottomConstraint?.constant = picker.frame.height * 1.5

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            if !self.presenting {
                self.isHidden = true
            }
        })
    }

    @objc func present(_: Any?) {
        layer.removeAllAnimations()

        picker.becomeFirstResponder()
        guard let _ = self.bottom else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.isHidden = false
                self.alpha = 1.0

            })
            return
        }

//        UIView.animate(withDuration: self.animationDuration) {
//            self.isHidden = false
//            self.bottomConstraint?.constant = 0
//            self.superview?.layoutIfNeeded()
//        }

        bottomConstraint?.constant = 0
        isHidden = false
        presenting = true

        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: { _ in
            self.presenting = false
        })
    }
}
