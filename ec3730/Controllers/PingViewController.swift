//
//  PingViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/24/18.
//  Copyright © 2018 Zachary Gorak. All rights reserved.
//

import Foundation

import SwiftyPing
import UIKit
import AddressURL

class PingViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    var status: UITextView?
    var urlBar: UITextField?

    var stack: UIStackView!

    // let preferredStatusBarStyle: UIStatusBarStyle = .lightContent

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

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
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack!]))

        status = UITextView()
        status?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        // TODO: black fade top and bottom
        // TODO: make this a constraint so there isn't padding when on the side
        status?.isEditable = false
        status?.isSelectable = true
        status?.backgroundColor = UIColor.black
        status?.textColor = UIColor.green
        status?.translatesAutoresizingMaskIntoConstraints = false
        status?.contentInset = view.safeAreaInsets
        status?.contentInset.bottom = 0
        status?.contentInsetAdjustmentBehavior = .always
        status?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        let statusView = UIView()
        statusView.addSubview(status!)

        stack.addArrangedSubview(statusView)

        let barStack = UIStackView()
        barStack.axis = NSLayoutConstraint.Axis.horizontal
        barStack.alignment = .leading
        // barStack.autoresizingMask = [.flexibleWidth]
        // stack.alignment = UIStackViewAlignment.Fill
        // stack.distribution = UIStackViewDistribution.FillProportionally
        barStack.spacing = 10
        barStack.translatesAutoresizingMaskIntoConstraints = false

        // urlBar = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        urlBar = UITextField()
        urlBar?.autocorrectionType = .no
        urlBar?.autocapitalizationType = .none
        urlBar?.textAlignment = .left
        urlBar?.borderStyle = .roundedRect
        urlBar?.keyboardType = .URL
        // urlBar?.autoresizingMask = [.flexibleWidth]
        urlBar?.placeholder = "1.1.1.1"
        urlBar?.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        urlBar?.delegate = self

        barStack.addArrangedSubview(urlBar!)

        let button = UIButton(type: .system)
        button.setTitle("ping", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(ping), for: .touchDown)
        barStack.addArrangedSubview(button)
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        barStack.addArrangedSubview(loader)

        let bar = UIToolbar()
        bar.barStyle = .default
        bar.setItems([UIBarButtonItem(customView: barStack)], animated: false)
        stack.addArrangedSubview(bar)

        loader.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loader.style = .medium
        } else {
            loader.style = .gray
        }

        let yConstraint = NSLayoutConstraint(item: loader, attribute: .centerY, relatedBy: .equal, toItem: barStack, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([yConstraint])

        startAvoidingKeyboard()
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

    func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
        if string == "\n" || string == "\r" {
            ping()
        }
        return true
    }

    func scrollViewDidScroll(_: UIScrollView) {
        dismissKeyboard()
    }

    public var pingCount: Int = 5

    private var latencySum: Double = 0.0
    private var minLatency: Double = Double.greatestFiniteMagnitude
    private var maxLatency: Double = Double.leastNormalMagnitude
    private var errorCount = 0

    public func resetStats() {
        latencySum = 0.0
        minLatency = Double.greatestFiniteMagnitude
        maxLatency = Double.leastNormalMagnitude
        errorCount = 0
    }

    func pingRepeated(_ url: URL, count: Int = 1) {
        self.isLoading = true
        
        guard let pinger = try? SwiftyPing(host: url.absoluteString, configuration: PingConfiguration(interval: 0.5, with: 5), queue: .global()) else {
            self.isLoading = false
            return
        }
        

        var count = 1
        self.maxLatency = Double.leastNormalMagnitude
        self.minLatency = Double.greatestFiniteMagnitude
        pinger.observer = { response in
            print(response)
            print(response.sequenceNumber)
            if let error = response.error {
                self.errorCount += 1
                switch error {
                case .addressLookupError:
                    self.status?.insertText("Address lookup failed.\n")
                case .addressMemoryError:
                    self.status?.insertText("Address data could not be converted to `sockaddr`.\n")
                case .checksumMismatch(_,_):
                    self.status?.insertText("The received checksum doesn't match the calculated one.\n")
                case .checksumOutOfBounds:
                    self.status?.insertText("Checksum is out-of-bounds for `UInt16` in `computeCheckSum`.\n")
                case .hostNotFound:
                    self.status?.insertText("Host was not found.\n")
                case .identifierMismatch(_,_):
                    self.status?.insertText("Response `identifier` doesn't match what was sent.\n")
                case .invalidCode(_):
                    self.status?.insertText("Response `code` was invalid.\n")
                case .invalidHeaderOffset:
                    self.status?.insertText("The ICMP header offset couldn't be calculated.\n")
                case .invalidLength(_):
                    self.status?.insertText("The response length was too short.\n")
                case .invalidSequenceIndex(_,_):
                    self.status?.insertText("Response `sequenceNumber` doesn't match.\n")
                case .invalidType(_):
                    self.status?.insertText("Response `type` was invalid.\n")
                case .packageCreationFailed:
                    self.status?.insertText("Unspecified package creation error.\n")
                case .requestError:
                    self.status?.insertText("An error occured while sending the request.\n")
                case .requestTimeout:
                    self.status?.insertText("The request send timed out.\n")
                case .responseTimeout:
                    self.status?.insertText("The response took longer to arrive than `configuration.timeoutInterval`.\n")
                case .socketNil:
                    self.status?.insertText("For some reason, the socket is `nil`.\n")
                case .socketOptionsSetError(_):
                    self.status?.insertText("Failed to change socket options, in particular SIGPIPE.\n")
                case .unexpectedPayloadLength:
                    self.status?.insertText("Unexpected payload length.\n")
                case .unknownHostError:
                    self.status?.insertText("Unknown error occured within host lookup.\n")
                }
            } else if let duration = response.duration {
                let latency = duration * 1000
                self.latencySum += latency
                if latency > self.maxLatency {
                    self.maxLatency = latency
                }
                if latency < self.minLatency {
                    self.minLatency = latency
                }
                self.status?.insertText(String(format: "latency=%0.3f ms\n", latency))
            }
            if count >= 5 {
                pinger.stopPinging()
                self.isLoading = false
                
                self.status?.insertText("--- \(url.absoluteString) ping statistics ---\n")

                // 5 packets transmitted, 5 packets received, 0.0% packet loss
                self.status?.insertText("\(count) packets transmitted, ")
                let received = count - self.errorCount
                self.status?.insertText("\(count - self.errorCount) received, ")
                if count == received {
                    self.status?.insertText("0.0% packet loss\n")
                } else if received == 0 {
                    self.status?.insertText("100% packet loss\n")
                } else {
                    self.status?.insertText(String(format: "%0.1f%% packet loss\n", Double(received) / Double(count) * 100.0))
                }

                // round-trip min/avg/max/stddev = 14.063/21.031/28.887/4.718 ms
                self.status?.insertText("latency min/avg/max = ")
                if self.errorCount == count {
                    self.status?.insertText("n/a\n")
                } else {
                    let avg = self.latencySum / Double(count)
                    self.status?.insertText(String(format: "%0.3f/%0.3f/%0.4f ms\n", self.minLatency, avg, self.maxLatency))
                }
                self.latencySum = 0.0
            }
            count = count + 1
            self.status?.scrollToBottom()
        }
        
        
        try? pinger.startPinging()
//        PlainPing.ping(url.absoluteString, withTimeout: 3.0, completionBlock: { (timeElapsed: Double?, error: Error?) in
//            if let latency = timeElapsed {
//                self.latencySum += latency
//                if latency > self.maxLatency {
//                    self.maxLatency = latency
//                }
//                if latency < self.minLatency {
//                    self.minLatency = latency
//                }
//                self.status?.insertText(String(format: "latency=%0.3f ms\n", latency))
//            }
//
//            if let error = error {
//                self.status?.insertText(error.localizedDescription + "\n")
//                self.errorCount += 1
//            }
//
//            if count >= self.pingCount {
//                if count > 1 {
//                    self.status?.insertText("--- \(url.absoluteString) ping statistics ---\n")
//
//                    // 5 packets transmitted, 5 packets received, 0.0% packet loss
//                    self.status?.insertText("\(count) packets transmitted, ")
//                    let received = count - self.errorCount
//                    self.status?.insertText("\(count - self.errorCount) received, ")
//                    if count == received {
//                        self.status?.insertText("0.0% packet loss\n")
//                    } else if received == 0 {
//                        self.status?.insertText("100% packet loss\n")
//                    } else {
//                        self.status?.insertText(String(format: "%0.1f%% packet loss\n", Double(received) / Double(count) * 100.0))
//                    }
//
//                    // round-trip min/avg/max/stddev = 14.063/21.031/28.887/4.718 ms
//                    self.status?.insertText("latency min/avg/max = ")
//                    if self.errorCount == count {
//                        self.status?.insertText("n/a\n")
//                    } else {
//                        let avg = self.latencySum / Double(count)
//                        self.status?.insertText(String(format: "%0.3f/%0.3f/%0.4f ms\n", self.minLatency, avg, self.maxLatency))
//                    }
//                    self.latencySum = 0.0
//                }
//                self.isLoading = false
//            } else {
//                self.pingRepeated(url, count: count + 1)
//            }
//
//        })
    }

    @objc
    func ping() {
        if !isLoading {
            var urlString = (urlBar?.text)!
            if urlString == "" {
                urlString = (urlBar?.placeholder)!
            }
            if let url = URL(string: urlString) {
                status?.insertText("PING " + url.absoluteString + "\n")
                isLoading = true
                resetStats()
                pingRepeated(url)
            } else {
                status?.insertText("Invalid URL\n")
            }
        }
    }
}
