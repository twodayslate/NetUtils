//
//  UISwitch.swift
//  acft
//
//  Created by Zachary Gorak on 5/30/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

class DefaultsSwitch: UISwitch {
    private var defaultKey: String

    public init(forKey key: String) {
        defaultKey = key
        super.init(frame: CGRect.zero)

        isOn = UserDefaults.standard.bool(forKey: defaultKey)
        addTarget(self, action: #selector(toggle), for: .valueChanged)
    }

    @objc private func toggle(_ sender: DefaultsSwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: sender.defaultKey)
        UserDefaults.standard.synchronize()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
