import Combine
import DeviceKit
import SwiftUI

class UIDeviceInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "UIDevice Information"

        Task { @MainActor in
            reload()
        }
    }

    @MainActor override func reload() {
        enabled = true
        rows.removeAll()

        rows.append(CopyCellView(title: "Model", content: UIDevice.current.model))
        rows.append(CopyCellView(title: "Localized Model", content: UIDevice.current.localizedModel))
        rows.append(CopyCellView(title: "Name", content: UIDevice.current.name))
        rows.append(CopyCellView(title: "System Name", content: UIDevice.current.systemName))
        rows.append(CopyCellView(title: "System Version", content: UIDevice.current.systemVersion))
        rows.append(CopyCellView(title: "UUID", content: UIDevice.current.identifierForVendor?.uuidString ?? "?"))
        rows.append(CopyCellView(title: "Idiom", content: UIDevice.current.userInterfaceIdiom.description ?? "?"))
        rows.append(CopyCellView(title: "Hardware Model", content: UIDevice.current.hwModel))
        rows.append(CopyCellView(title: "Hardware Machine", content: UIDevice.current.hwMachine))
        rows.append(CopyCellView(title: "Disk Space Available", content: "\(UIDevice.current.freeDiskSpaceInBytes) bytes"))
        rows.append(CopyCellView(title: "Total Disk Space", content: "\(UIDevice.current.totalDiskSpaceInBytes) bytes"))
        rows.append(CopyCellView(title: "Supports Multitasking", content: UIDevice.current.isMultitaskingSupported ? "Yes" : "No"))

        if let bootTime = UIDevice.current.boottime {
            rows.append(CopyCellView(title: "Boot time", content: "\(bootTime)"))
            rows.append(CopyCellView(title: "Total Uptime", content: "\(UIDevice.current.uptime)"))
        }

        if UIDevice.current.batteryLevel >= 0, UIDevice.current.batteryState != .unknown, UIDevice.current.isBatteryMonitoringEnabled {
            rows.append(CopyCellView(title: "Battery Level", content: "\(UIDevice.current.batteryLevel * 100)%"))
            rows.append(CopyCellView(title: "Battery State", content: "\(UIDevice.current.batteryState.description ?? "?")"))
        } else {
            rows.append(CopyCellView(title: "Battery", content: "Battery monitoring is not enabled"))
        }
    }
}
