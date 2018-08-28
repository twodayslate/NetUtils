//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import PlainPing

class PingViewController : UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    var status : UITextView?
    var urlBar : UITextField?
    
    var stack : UIStackView! = nil
    
    //let preferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        stack = UIStackView()
        stack.backgroundColor = UIColor.black
        stack.axis = UILayoutConstraintAxis.vertical
        //stack.alignment = UIStackViewAlignment.fill
        //stack.alignment = .top
        //stack.distribution = UIStackViewDistribution.fillProportionally
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))

        status = UITextView()
        status?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
        // TODO: make this a constraint so there isn't padding when on the side
        status?.isEditable = false
        status?.isSelectable = true
        status?.backgroundColor = UIColor.black
        status?.textColor = UIColor.green
        status?.translatesAutoresizingMaskIntoConstraints = false
        status?.contentInset = self.view.safeAreaInsets
        status?.contentInset.bottom = 0
        status?.contentInsetAdjustmentBehavior = .always
        status?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let statusView = UIView()
        statusView.addSubview(status!)
        
        self.stack.addArrangedSubview(statusView)
        
        let barStack = UIStackView()
        barStack.axis = UILayoutConstraintAxis.horizontal
        barStack.alignment = .leading
        //barStack.autoresizingMask = [.flexibleWidth]
        //stack.alignment = UIStackViewAlignment.Fill
        //stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        barStack.translatesAutoresizingMaskIntoConstraints = false
        
        //urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        //urlBar?.textColor = UIColor.black
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        //urlBar?.autoresizingMask = [.flexibleWidth]
        urlBar?.placeholder = "google.com"
        urlBar?.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        urlBar?.delegate = self
        
        barStack.addArrangedSubview(urlBar!)
        
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        button.setTitle("ping", for: .normal)
        button.addTarget(self, action: #selector(ping), for: .touchDown)
        barStack.addArrangedSubview(button)
        
        let bar = UIToolbar()
        bar.barStyle = .blackTranslucent
        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        self.stack.addArrangedSubview(bar)
        
        self.startAvoidingKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAvoidingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopAvoidingKeyboard()
    }
    
    // TODO: do this with constraints
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
//        status?.contentInset = self.view.safeAreaInsets
//        status?.contentInset.bottom = 0
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n" || string == "\r") {
            self.ping()
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
    @objc
    func ping() {
        var urlString = (urlBar?.text)!
        if(urlString == "") {
            urlString = (urlBar?.placeholder)!
        }
        if let url = URL(string: urlString) {
            print("Going to ping", url)
            PlainPing.ping(url.absoluteString, withTimeout: 3.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
                if let latency = timeElapsed {
                    self.status?.insertText("latency (ms): \(latency)\n")
                }
                
                if let error = error {
                    self.status?.insertText(error.localizedDescription+"\n")
                }
            })
        } else {
            self.status?.insertText("Invalid URL\n")
        }
    }
    
}
