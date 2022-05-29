//
//  Utility.swift
//  ec3730
//
//  Created by Ahmad Azam on 29/05/2022.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation

public func loadJson(filename fileName: String) -> Data? {
    var result: Data?
    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
        do {
            result = try Data(contentsOf: url)
        } catch {
            print("error:\(error)")
        }
    }
    return result
}
