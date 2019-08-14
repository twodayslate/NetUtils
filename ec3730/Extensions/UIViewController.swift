//
//  UIViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/27/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

/**
 * Reference: https://stackoverflow.com/questions/45399178/extend-ios-11-safe-area-to-include-the-keyboard
 */
extension UIViewController {
    func startAvoidingKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }

    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        if #available(iOS 11.0, *) {
            guard let userInfo = notification.userInfo,
                let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }

            let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
            let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
            let intersection = safeAreaFrame.intersection(keyboardFrameInView)

            let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
                self.additionalSafeAreaInsets.bottom = intersection.height
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func dismissKeyboard() {
        resignFirstResponder()
        view.endEditing(false)
    }
}

extension UIViewController {
    open func showError(_ title: String = "Error", message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            alert.addActionSheetForiPad()
            self.present(alert, animated: true, completion: nil)
        }
    }

    open func alert(with message: String, title _: String? = nil, cancelTitle: String = "Okay") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            alert.addActionSheetForiPad()
            self.present(alert, animated: true, completion: nil)
        }
    }

    open func alert(with error: Error, cancelTitle: String = "Okay") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: error.title, message: error.localizedDescription, preferredStyle: .alert)

            if let localized = error.localized {
                if let helpAnchor = localized.helpAnchor {
                    let help = UIAlertAction(title: "Help", style: .cancel) { _ in
                        self.alert(with: helpAnchor)
                    }
                    alert.addAction(help)
                }

                if let recoverySuggestion = localized.recoverySuggestion {
                    let recovery = UIAlertAction(title: "Recovery Suggestion", style: .cancel) { _ in
                        self.alert(with: recoverySuggestion)
                        // Add

                        if let _ = error as? RecoverableError {
                            // TODO: add actions
                        }
                    }
                    alert.addAction(recovery)
                }
            }

            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            alert.addActionSheetForiPad()
            self.present(alert, animated: true, completion: nil)
        }
    }
}
