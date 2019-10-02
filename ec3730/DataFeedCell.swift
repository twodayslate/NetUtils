//
//  DataFeedCell.swift
//  ec3730
//
//  Created by Zachary Gorak on 9/26/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DataFeedCell: UITableViewCell {
    var owned: Bool {
        return subscriber.isSubscribed
    }

    let name: String
    let subscriber: WhoisXml.Type

    init(_ name: String, subscriber: WhoisXml.Type) {
        self.name = name
        self.subscriber = subscriber
        super.init(style: .value1, reuseIdentifier: name)

        textLabel?.text = name
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
