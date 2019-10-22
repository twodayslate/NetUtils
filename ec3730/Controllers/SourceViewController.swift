//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation
import Highlightr
import SplitView
import UIKit
import WebKit

class SourceBar: UIToolbar {
    func position(for _: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    override var barPosition: UIBarPosition {
        return .topAttached
    }
}

class SourceViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    var sourceView: UITextView?
    var urlBar: UITextField?
    var button: UIButton?
    let highlighter = Highlightr()
    var language = UIBarButtonItem()
    let languagePicker = UIPickerView()
    var blurredPicker: BlurredPickerView?

    var stack: UIStackView!
    let barStack = UIStackView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        // XXX: should this be based on the content of the web view?
        return .default
    }

    var browser: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = .white
        }

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

        let splitStackView = SplitView()
        splitStackView.axis = .vertical
        splitStackView.snap = [.quarter]
        splitStackView.translatesAutoresizingMaskIntoConstraints = false
        splitStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

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
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        urlBar?.clearButtonMode = .whileEditing
        urlBar?.placeholder = "https://google.com/"
        urlBar?.delegate = self

        barStack.addArrangedSubview(urlBar!)

        let button = UIButton(type: .system)
        button.setTitle("View Source", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(viewSource), for: .touchDown)
        barStack.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        barStack.addArrangedSubview(loader)

        let bar = SourceBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.barStyle = .default

        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        stack.addArrangedSubview(bar)

        stack.addArrangedSubview(splitStackView)

//        let textStorage = CodeAttributedString()
//        textStorage.language = "HTML"
//        let layoutManager = NSLayoutManager()
//        textStorage.addLayoutManager(layoutManager)
//
//        let textContainer = NSTextContainer(size: view.bounds.size)
//        layoutManager.addTextContainer(textContainer)
//
//        sourceView = UITextView(frame: .zero, textContainer: textContainer)

        sourceView = UITextView()
        // sourceView?.textContainer.layoutManager.store
        // sourceView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
//        let topPadding = max(view.frame.size.height - view.safeAreaLayoutGuide.layoutFrame.size.height, UIApplication.shared.statusBarFrame.height)
//        sourceView?.contentInset.top = topPadding

        let sourceWrapper = UIView()
        sourceWrapper.translatesAutoresizingMaskIntoConstraints = false
        sourceView?.isEditable = false
        sourceView?.isSelectable = true
        sourceView?.translatesAutoresizingMaskIntoConstraints = false
        sourceView?.clearsOnInsertion = true

        let sourceStack = UIStackView()
        sourceStack.axis = .vertical
        sourceStack.translatesAutoresizingMaskIntoConstraints = false

        let sourceBar = UIToolbar()
        sourceBar.translatesAutoresizingMaskIntoConstraints = false

//        language.frame = CGRect(x: 0, y: 0, width: 550, height: sourceBar.frame.height)
//        language.text = "HTML"
//        language.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
//        language.backgroundColor = .clear
//        language.tintColor = .clear
//        language.isEditable = false
//        language.textAlignment = .center
        language = UIBarButtonItem(title: "HTML", style: .done, target: self, action: #selector(selectLanguages))

        // languagePicker.backgroundColor = UIColor.lightGray.withAlphaComponent(0.9)

        // blurBackground.translatesAutoresizingMaskIntoConstraints = false
        // languagePicker.insertSubview(blurBackground, at: 0)
        // languagePicker.sendSubviewToBack(blurBackground)

//        languagePicker.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": blurBackground]))
//        languagePicker.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": blurBackground]))

        blurredPicker = BlurredPickerView(picker: languagePicker, style: .regular)

        languagePicker.delegate = self
        languagePicker.dataSource = self

        view.addSubview(blurredPicker!)
//        blurredPicker?.isHidden = true
//        blurredPicker?.alpha = 0.0

        sourceBar.items = [
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadJavascript)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            language,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectSource(_:))),
            UIBarButtonItem(title: "Copy", style: .plain, target: self, action: #selector(copySource(_:)))
        ]
        sourceStack.addArrangedSubview(sourceBar)
        sourceStack.addArrangedSubview(sourceView!)

        let browserWrapper = UIView()
        browserWrapper.translatesAutoresizingMaskIntoConstraints = false
        browser = WKWebView()
        browser.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        browser.navigationDelegate = self
        browser.allowsBackForwardNavigationGestures = true

        browserWrapper.addSubview(browser)
        splitStackView.addSplitSubview(browserWrapper, desiredRatio: 0.5, minimumRatio: 0.1)

        sourceWrapper.addSubview(sourceStack)
        splitStackView.addSplitSubview(sourceWrapper, desiredRatio: 0.5, minimumRatio: 0.1)
        // stack.addArrangedSubview(sourceView!)

//        sourceView?.topAnchor.constraint(equalTo: sourceWrapper.topAnchor).isActive = true
//        sourceView?.bottomAnchor.constraint(equalTo: sourceWrapper.bottomAnchor).isActive = true
//        sourceView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        sourceView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        loader.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loader.style = .medium
        } else {
            loader.style = .gray
        }
        let yConstraint = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])

        // bar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

        bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true

        sourceWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": sourceStack]))
        sourceWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": sourceStack]))

//        language.centerXAnchor.constraint(equalTo: sourceBar.centerXAnchor).isActive = true
        // language.widthAnchor.constraint(greaterThanOrEqualTo: sourceBar.widthAnchor, multiplier: 0.3).isActive = true

        blurredPicker?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blurredPicker?.bottom = view.safeAreaLayoutGuide.bottomAnchor
        blurredPicker?.isHidden = true
        blurredPicker?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurredPicker?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

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
            showError("Error", message: "Invalid URL")
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

    @objc func selectSource(_ sender: Any?) {
        DispatchQueue.main.async {
            self.sourceView?.selectAll(sender)
        }
    }

    @objc func copySource(_: Any?) {
        UIPasteboard.general.string = sourceView?.text
    }

    @objc func selectLanguages() {
        blurredPicker?.present(nil)
    }
}

extension SourceViewController: WKNavigationDelegate {
    @objc func reloadJavascript() {
        setJavascript(showErrors: false, completion: nil)
    }

    private func setJavascript(showErrors: Bool = true, completion block: (() -> Void)? = nil) {
        browser.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { source, error in

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

            // Highlighter is slow af so doing this instead of using a text container
            DispatchQueue(label: "highlight", qos: .userInitiated).async {
                let highlightedCode = self.highlighter?.highlight(source, as: self.language.title
                    ?? "html", fastRender: true)
                DispatchQueue.main.async {
                    self.sourceView?.attributedText = highlightedCode
                    block?()
                }
            }
        })
    }

    func webView(_: WKWebView, didCommit _: WKNavigation!) {
        print("comitting")
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        print("finished")
        urlBar?.text = webView.url?.absoluteString
        setJavascript {
            print("done")

            self.isLoading = false
        }
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        print("failed")
        setJavascript {
            self.isLoading = false
        }
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        DispatchQueue.main.async {
            self.sourceView?.attributedText = nil
        }
        isLoading = true
    }
}

extension SourceViewController: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        if row == 0 {
            return "HTML"
        }
        if row == 1 {
            return nil
        }
        return highlighter?.supportedLanguages()[row - 2] ?? nil
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if row == 0 || row == 1 {
            language.title = "HTML"
            return
        }
        language.title = highlighter?.supportedLanguages()[row - 2] ?? "HTML"
    }
}

extension SourceViewController: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        guard let languages = highlighter?.supportedLanguages() else {
            return 1
        }
        return languages.count + 2
    }
}
