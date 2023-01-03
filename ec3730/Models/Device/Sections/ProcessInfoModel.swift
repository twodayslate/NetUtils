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

        rows.append(.row(title: "Proces Name", content: info.processName))
        rows.append(.row(title: "Active Processors", content: "\(info.activeProcessorCount)"))
        rows.append(.row(title: "Hostname", content: "\(info.hostName)"))
        rows.append(.row(title: "Process Arguments", content: "\(info.arguments.joined(separator: " "))"))
        rows.append(.row(title: "Low Power Mode", content: info.isLowPowerModeEnabled ? "Enabled" : "Disabled"))
        rows.append(.toggleableRow(title: "Physical Memory", contents: [
            "\(info.physicalMemory) bytes",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0)) kiB",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0 / 1024.0)) MiB",
            "\(String(format: "%0.1f", Double(info.physicalMemory) / 1024.0 / 1024.0 / 1024.0)) GiB",
        ]))
        rows.append(.row(title: "Globally Unique String", content: "\(info.globallyUniqueString)"))
        rows.append(.row(title: "OS Version", content: info.operatingSystemVersionString))
        rows.append(.row(title: "System Uptime", content: "\(info.systemUptime)"))
        rows.append(.row(title: "Is Mac Catalyst App", content: info.isMacCatalystApp ? "Yes" : "No"))
        rows.append(.row(title: "Is iOS App on Mac", content: info.isiOSAppOnMac ? "Yes" : "No"))
        rows.append(.row(title: "Prcoess Identifier (PID)", content: "\(info.processIdentifier)"))
        rows.append(.row(title: "Thermal State", content: info.thermalState.description))

        func getArchitecture() -> NSString {
            let info = NXGetLocalArchInfo()
            return NSString(utf8String: (info?.pointee.description)!)!
        }
        rows.append(.row(title: "Architecture", content: getArchitecture() as String))
    }
}
