//
//  DataFeedUserApiKeyTableViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class UserApiKeyFooterView: UITableViewHeaderFooterView {
    let label = UITextView()
    let subscriber: DataFeed

    /// https://developer.apple.com/design/human-interface-guidelines/subscriptions/overview/
    func legaleeze(color _: UIColor = .systemGray) -> NSMutableAttributedString {
        // swiftlint:disable line_length
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center

        let link = NSMutableAttributedString(string: "Manage your API key from \(subscriber.name)", attributes: [NSAttributedString.Key.link: subscriber.webpage.absoluteString, NSAttributedString.Key.paragraphStyle: paragraphStyle])

        return link
    }

    init(subscriber: DataFeed) {
        self.subscriber = subscriber
        super.init(reuseIdentifier: "UserAPIKeyFooter")

        label.isEditable = false
        label.isScrollEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        // label.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        label.backgroundColor = .clear

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(label)

        label.attributedText = legaleeze()

        contentView.addSubview(stack)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InputTableViewCell: UITableViewCell {
    let input = UITextField()

    init() {
        super.init(style: .default, reuseIdentifier: "input")

        contentView.addSubview(input)
        input.translatesAutoresizingMaskIntoConstraints = false
        selectionStyle = .none
        input.autocorrectionType = .no
        input.clearButtonMode = .whileEditing

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": input]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": input]))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol DataFeedUserApiKeyDelegate: AnyObject {
    func didUpdateUserApiKey(_ feed: DataFeed)
}

class DataFeedUserApiKeyController: UINavigationController {
    let subscriber: DataFeed
    var userApiDelegate: DataFeedUserApiKeyDelegate? {
        didSet {
            tableController.userApiDelegate = userApiDelegate
        }
    }

    var tableController: DataFeedUserApiKeyTableViewController

    init(subscriber: DataFeed) {
        self.subscriber = subscriber
        tableController = DataFeedUserApiKeyTableViewController(subscriber: subscriber)
        super.init(rootViewController: tableController)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataFeedUserApiKeyTableViewController: UITableViewController {
    let subscriber: DataFeed
    var userApiDelegate: DataFeedUserApiKeyDelegate?

    init(subscriber: DataFeed) {
        self.subscriber = subscriber
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = subscriber.name

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save(_:)))
    }

    @objc func save(_: Any?) {
        dismiss(animated: true, completion: nil)
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = InputTableViewCell()
        cell.input.placeholder = "API Key"
        cell.input.text = subscriber.userKey
        cell.input.addTarget(self, action: #selector(updateKey(_:)), for: .editingDidEnd)
        return cell
    }

    @objc func updateKey(_ sender: UITextField?) {
        guard let keyText = sender?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            subscriber.userKey = nil
            return
        }

        if keyText.isEmpty {
            subscriber.userKey = nil
        } else {
            subscriber.userKey = keyText
        }

        userApiDelegate?.didUpdateUserApiKey(subscriber)
    }

    override func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footer = UserApiKeyFooterView(subscriber: subscriber)
        footer.label.delegate = self
        return footer
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension DataFeedUserApiKeyTableViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        open(URL, title: "")
        return false
    }
}
