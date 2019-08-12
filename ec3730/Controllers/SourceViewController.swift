//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit
import Highlightr

class SourceViewController : UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    var sourceView : UITextView?
    var urlBar : UITextField?
    var button : UIButton?
    
    var stack : UIStackView! = nil
    let barStack = UIStackView()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        UIApplication.shared.statusBarStyle = .default
        
        stack = UIStackView()
        stack.backgroundColor = UIColor.black
        stack.axis = NSLayoutConstraint.Axis.vertical
        //stack.alignment = UIStackViewAlignment.fill
        //stack.alignment = .top
        //stack.distribution = UIStackViewDistribution.fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        
        sourceView = UITextView()
        sourceView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
        let topPadding = max(self.view.frame.size.height - self.view.safeAreaLayoutGuide.layoutFrame.size.height, UIApplication.shared.statusBarFrame.height)
        sourceView?.contentInset.top = topPadding
        sourceView?.isEditable = false
        sourceView?.isSelectable = true
        sourceView?.translatesAutoresizingMaskIntoConstraints = false
        sourceView?.clearsOnInsertion = true
        sourceView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.stack.addArrangedSubview(sourceView!)
        
        
        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        //barStack.autoresizingMask = [.flexibleWidth]
        //stack.alignment = UIStackViewAlignment.Fill
        //stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        //barStack.translatesAutoresizingMaskIntoConstraints = false
        
        //urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        urlBar?.textColor = UIColor.black
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        urlBar?.placeholder = "https://google.com"
        urlBar?.delegate = self
        
        barStack.addArrangedSubview(urlBar!)
        
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 120, height: 50))
        button.setTitle("View Source", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(viewSource), for: .touchDown)
        barStack.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        barStack.addArrangedSubview(loader)
        
        let bar = UIToolbar()
        bar.barStyle = .blackTranslucent
        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        self.stack.addArrangedSubview(bar)
        
        loader.hidesWhenStopped = true
        let yConstraint = NSLayoutConstraint(item: self.loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])
        self.startAvoidingKeyboard()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n" || string == "\r") {
            self.viewSource()
            return false
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startAvoidingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopAvoidingKeyboard()
    }
    
    private var _isLoading = false
    var isLoading : Bool {
        get {
            return _isLoading
        }
        set {
            DispatchQueue.main.async {
                if newValue {
                    self.loader.startAnimating()
                } else {
                    self.loader.stopAnimating()
                }
            }
            _isLoading = newValue
        }
    }
    let loader = UIActivityIndicatorView()
    
    @objc
    func viewSource() {
        if(isLoading) { return }
        
        var urlString = (urlBar?.text)!
        if(urlString == "") {
            urlString = (urlBar?.placeholder)!
        }
        if let url = URL(string: urlString) {
            print("Viewing source for: ", url)
            isLoading = true
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let source = try String(contentsOf: url, encoding: .ascii)
                    let highlightr = Highlightr()
                    let highlightedCode = highlightr?.highlight(source)
                    DispatchQueue.main.async {
                        self.sourceView?.attributedText = highlightedCode
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                   //self.status?.insertText(error.localizedDescription)
                }
                
                self.isLoading = false
            }
        } else {
            //self.status?.insertText("Invalid URL\n")
            let alert = UIAlertController(title: "Error", message: "Invalid URL", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
