//
//  GoogleWebRiskRecord.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/17/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

struct GoogleWebRiskRecordWrapper: Codable {
    var threat: GoogleWebRiskRecord?
}

struct GoogleWebRiskRecord: Codable {
    var threatTypes: [GoogleWebRisk.ThreatTypes]
    var expireTime: Date
}
