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
        rows.append(CopyCellView(title: "Wifi", rows: [CopyCellRow(title: "Send / Recieve", content: SystemDataUsage.wifiTotal)]))
        rows.append(CopyCellView(title: "Cellular", rows: [CopyCellRow(title: "Send / Recieve", content: SystemDataUsage.wwanTotal)]))
    }
}
