//
//  Encodable.swift
//  ec3730
//
//  Created by Zachary Gorak on 12/29/22.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
