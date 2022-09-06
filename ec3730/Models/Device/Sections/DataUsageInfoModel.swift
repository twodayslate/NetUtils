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
        rows.append(CopyCellView(title: "Wifi", rows: [CopyCellRow(title: "Sent", content: SystemDataUsage.wifiSent), CopyCellRow(title: "Received", content: SystemDataUsage.wifiReceived), CopyCellRow(title: "Total", content: SystemDataUsage.wifiTotal)]))
        rows.append(CopyCellView(title: "Cellular", rows: [CopyCellRow(title: "Sent", content: SystemDataUsage.wwanSent), CopyCellRow(title: "Received", content: SystemDataUsage.wwanReceived), CopyCellRow(title: "Total", content: SystemDataUsage.wwanTotal)]))
    }
}
