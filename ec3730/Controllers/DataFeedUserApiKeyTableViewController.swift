//
//  DataFeedUserApiKeyTableViewController.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/15/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class InputTableViewCell: UITableViewCell {
    let input = UITextField()
    
    
    init() {
        super.init(style: .default, reuseIdentifier: "input")
        
        
        self.contentView.addSubview(input)
        input.translatesAutoresizingMaskIntoConstraints = false
        self.selectionStyle = .none
        input.autocorrectionType = .no
        input.clearButtonMode = .whileEditing
        
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": input]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[scrollview]-|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": input]))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol DataFeedUserApiKeyDelegate: class {
    func didUpdate()
}

class DataFeedUserApiKeyController: UINavigationController {
    let subscriber: DataFeed.Type
    var userApiDelegate: DataFeedUserApiKeyDelegate? = nil {
        didSet {
            self.tableController.userApiDelegate = self.userApiDelegate
        }
    }
    
    var tableController: DataFeedUserApiKeyTableViewController
    
    
    
    init(subscriber: DataFeed.Type) {
        self.subscriber = subscriber
        self.tableController = DataFeedUserApiKeyTableViewController(subscriber: subscriber)
        super.init(rootViewController: self.tableController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataFeedUserApiKeyTableViewController: UITableViewController {
    let subscriber: DataFeed.Type
    var userApiDelegate: DataFeedUserApiKeyDelegate? = nil
    
    init(subscriber: DataFeed.Type) {
        self.subscriber = subscriber
        super.init(style: .grouped)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.subscriber.name
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.save(_:)))
    }
    
    @objc func save(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
        
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InputTableViewCell()
        cell.input.placeholder = "API Key"
        cell.input.text = UserDefaults.standard.string(forKey: UserDefaults.NetUtils.Keys.whoisXMLUserApiKey)
        cell.input.addTarget(self, action: #selector(updateKey(_:)), for: .editingDidEnd)
        return cell
    }
    
    @objc func updateKey(_ sender: UITextField?) {
        guard let keyText = sender?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            self.subscriber.userKey = nil
            UserDefaults.standard.set(nil, forKey: UserDefaults.NetUtils.Keys.whoisXMLUserApiKey)
            return
        }
        
        if keyText.isEmpty {
            self.subscriber.userKey = nil
            UserDefaults.standard.set(nil, forKey: UserDefaults.NetUtils.Keys.whoisXMLUserApiKey)
        } else {
            UserDefaults.standard.set(keyText, forKey: UserDefaults.NetUtils.Keys.whoisXMLUserApiKey)
            self.subscriber.userKey = ApiKey(name: self.subscriber.name, key: keyText)
        }
        UserDefaults.standard.synchronize()
        
        self.userApiDelegate?.didUpdate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
