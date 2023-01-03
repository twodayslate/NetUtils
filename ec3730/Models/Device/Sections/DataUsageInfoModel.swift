//
//  DataUsageInfoModel.swift
//  ec3730
//
//  Created by Ahmad Azam on 21/08/2022.
//  Copyright © 2022 Zachary Gorak. All rights reserved.
//

import SwiftUI

class DataUsageInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "Data Usage"

        Task { @MainActor in
            reload()
        }
    }

    @MainActor override func reload() {
        enabled = true
        SystemDataUsage.reload()
        rows.removeAll()
        rows.append(.multiple(title: "Wifi", contents: [
            .row(title: "Sent", content: SystemDataUsage.wifiSent, style: .expandable),
            .row(title: "Received", content: SystemDataUsage.wifiReceived, style: .expandable),
            .row(title: "Total", content: SystemDataUsage.wifiTotal, style: .expandable),
        ]))
        rows.append(.multiple(title: "Cellular", contents: [
            .row(title: "Sent", content: SystemDataUsage.wwanSent, style: .expandable),
            .row(title: "Received", content: SystemDataUsage.wwanReceived, style: .expandable),
            .row(title: "Total", content: SystemDataUsage.wwanTotal, style: .expandable),
        ]))
    }
}
