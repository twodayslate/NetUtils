//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import Highlightr
import UIKit
import WebKit
class SourceViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    var sourceView: UITextView?
    var urlBar: UITextField?
    var button: UIButton?

    var stack: UIStackView!
    let barStack = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    var browser: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        stack = UIStackView()
        stack.backgroundColor = UIColor.black
        stack.axis = NSLayoutConstraint.Axis.vertical
        // stack.alignment = UIStackViewAlignment.fill
        // stack.alignment = .top
        // stack.distribution = UIStackViewDistribution.fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))

        
        let splitStackView = SplitStackView()
        splitStackView.translatesAutoresizingMaskIntoConstraints = false
        splitStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        stack.addArrangedSubview(splitStackView)
        
        sourceView = UITextView()
        //sourceView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
//        let topPadding = max(view.frame.size.height - view.safeAreaLayoutGuide.layoutFrame.size.height, UIApplication.shared.statusBarFrame.height)
//        sourceView?.contentInset.top = topPadding
        

        let sourceWrapper = UIView()
        sourceWrapper.translatesAutoresizingMaskIntoConstraints = false
        sourceView?.isEditable = false
        sourceView?.isSelectable = true
        sourceView?.translatesAutoresizingMaskIntoConstraints = false
        sourceView?.clearsOnInsertion = true
        
        let browserWrapper = UIView()
        browserWrapper.translatesAutoresizingMaskIntoConstraints = false
        browser = WKWebView()
        browser.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        browser.navigationDelegate = self
        browser.allowsBackForwardNavigationGestures = true
        
        browserWrapper.addSubview(browser)
        splitStackView.addView(browserWrapper, ratio: 0.5, minRatio: 0.1)
        sourceWrapper.addSubview(sourceView!)
        splitStackView.addView(sourceWrapper, ratio: 0.5, minRatio: 0.1)
        //stack.addArrangedSubview(sourceView!)

        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        // barStack.autoresizingMask = [.flexibleWidth]
        // stack.alignment = UIStackViewAlignment.Fill
        // stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        // barStack.translatesAutoresizingMaskIntoConstraints = false

        // urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        urlBar?.textColor = UIColor.black
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        urlBar?.clearButtonMode = .whileEditing
        urlBar?.placeholder = "https://google.com/"
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
        stack.addArrangedSubview(bar)

        
        sourceView?.topAnchor.constraint(equalTo: sourceWrapper.topAnchor).isActive = true
        sourceView?.bottomAnchor.constraint(equalTo: sourceWrapper.bottomAnchor).isActive = true
        sourceView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        sourceView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        loader.hidesWhenStopped = true
        let yConstraint = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])
        
        startAvoidingKeyboard()
    }

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\r" {
            viewSource()
            return false
        }
        return true
    }

    func scrollViewDidScroll(_: UIScrollView) {
        dismissKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAvoidingKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopAvoidingKeyboard()
    }

    private var _isLoading = false
    var isLoading: Bool {
        get {
            return _isLoading
        }
        set {
            DispatchQueue.main.async {
                if newValue {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    self.loader.startAnimating()
                } else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.loader.stopAnimating()
                }
            }
            _isLoading = newValue
        }
    }

    let loader = UIActivityIndicatorView()

    @objc
    func viewSource() {
        if isLoading { return }

        var urlString = (urlBar?.text)!
        if urlString == "" {
            urlString = (urlBar?.placeholder)!
        }
        
        guard var url = URL(string: urlString) else {
            self.showError("Error", message: "Invalid URL")
            return
        }
        
        var components: URLComponents?
        
        if url.scheme == nil {
            components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.scheme = "https"
            url = components?.url ?? url
        }

        print("Viewing source for: ", url.absoluteString)
        DispatchQueue.main.async {
            self.browser.load(URLRequest(url: url))
        }
    }
}

extension SourceViewController: WKNavigationDelegate {
    private func setJavascript(showErrors: Bool = true, completion block: (()->Void)? = nil) {
        self.browser.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { (source, error) in
            
            guard error == nil else {
                if showErrors {
                    self.showError("Error", message: error!.localizedDescription)
                }
                block?()
                return
            }
            
            guard let source = source as? String else {
                if showErrors {
                    self.showError("Error", message: "Unable to parse source")
                }
                block?()
                return
            }
            
            DispatchQueue.init(label: "highlight", qos: .userInitiated).async {
                let highlightr = Highlightr()
                let highlightedCode = highlightr?.highlight(source)
                DispatchQueue.main.async {
                    self.sourceView?.attributedText = highlightedCode
                    block?()
                }
            }
        })
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("comitting")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finished")
        self.urlBar?.text = webView.url?.absoluteString
        self.setJavascript {
            print("done")
            
            self.isLoading = false
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("failed")
        self.setJavascript {
            self.isLoading = false
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.sourceView?.attributedText = nil
        }
        self.isLoading = true
    }
}
