import Combine
import DeviceKit
import MachO
import SwiftUI

extension ProcessInfo.ThermalState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .critical:
            return "Critical"
        case .nominal:
            return "Nominal"
        case .fair:
            return "Fair"
        case .serious:
            return "Serious"
        @unknown default:
            return "Unknown"
        }
    }
}

class ProcessInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "Process Information"

        Task { @MainActor in
            reload()
        }
    }

    @MainActor override func reload() {
        enabled = true
        rows.removeAll()

        let info = ProcessInfo.processInfo

        rows.append(CopyCellView(title: "Proces Name", content: info.processName))
        rows.append(CopyCellView(title: "Active Processors", content: "\(info.activeProcessorCount)"))
        rows.append(CopyCellView(title: "Hostname", content: "\(info.hostName)"))
        rows.append(CopyCellView(title: "Process Arguments", content: "\(info.arguments.joined(separator: " "))"))
        rows.append(CopyCellView(title: "Low Power Mode", content: info.isLowPowerModeEnabled ? "Enabled" : "Disabled"))
        rows.append(CopyCellView(title: "Physical Memory", contents: [
            "\(info.physicalMemory) bytes",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0)) kiB",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0 / 1024.0)) MiB",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0 / 1024.0 / 1024.0)) GiB",
        ]))
        rows.append(CopyCellView(title: "Globally Unique String", content: "\(info.globallyUniqueString)"))
        rows.append(CopyCellView(title: "OS Version", content: info.operatingSystemVersionString))
        rows.append(CopyCellView(title: "System Uptime", content: "\(info.systemUptime)"))
        rows.append(CopyCellView(title: "Is Mac Catalyst App", content: info.isMacCatalystApp ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Is iOS App on Mac", content: info.isiOSAppOnMac ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Prcoess Identifier (PID)", content: "\(info.processIdentifier)"))
        rows.append(CopyCellView(title: "Thermal State", content: info.thermalState.description))

        func getArchitecture() -> NSString {
            let info = NXGetLocalArchInfo()
            return NSString(utf8String: (info?.pointee.description)!)!
        }
        rows.append(CopyCellView(title: "Architecture", content: getArchitecture() as String))
    }
}
