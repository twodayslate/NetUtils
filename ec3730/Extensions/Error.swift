//
//  Error.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/13/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

extension Error {
    var localized: LocalizedError? {
        return self as? LocalizedError
    }

    var title: String {
        return "Error"
    }
}
