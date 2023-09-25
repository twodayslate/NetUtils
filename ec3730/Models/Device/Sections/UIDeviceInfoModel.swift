import Combine
import DeviceKit
import SwiftUI

/// Device information from ``UIDevice`` and ``DeviceKit``
class UIDeviceInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "Device Information"
    }

    @MainActor override func reload() async {
        enabled = true
        rows.removeAll()

        rows.append(.row(title: "Model", content: UIDevice.current.model))
        rows.append(.row(title: "Localized Model", content: UIDevice.current.localizedModel))
        rows.append(.row(title: "Name", content: UIDevice.current.name))
        rows.append(.row(title: "System Name", content: UIDevice.current.systemName))
        rows.append(.row(title: "System Version", content: UIDevice.current.systemVersion))
        rows.append(.row(title: "UUID", content: UIDevice.current.identifierForVendor?.uuidString ?? "?"))
        rows.append(.row(title: "Idiom", content: UIDevice.current.userInterfaceIdiom.description ?? "?"))
        rows.append(.row(title: "Hardware Model", content: UIDevice.current.hwModel))
        rows.append(.row(title: "Hardware Machine", content: UIDevice.current.hwMachine))

        // "kB", "MB", "GB", "TB", "PB", "EB", "ZB", and "YB" for SI units (base 1000).
        // "kiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", and "YiB" for binary units (base 1024).

        let importantFreeDiskSpaceInBytes = await UIDevice.current.asyncImportantFreeDiskSpaceInBytes
        let opportunisticFreeDiskSpaceInBytes = await UIDevice.current.asyncOpportunisticFreeDiskSpaceInBytes
        let realFreeDiskSpaceInBytes = UIDevice.current.realFreeDiskSpaceInBytes

        rows.append(.multiple(title: "Disk Space Available", contents: [
            .toggleableRow(title: "Important", contents: [
                "\(importantFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(importantFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(importantFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(importantFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ], style: .expandable),
            .toggleableRow(title: "Opportunistic", contents: [
                "\(opportunisticFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(opportunisticFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(opportunisticFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(opportunisticFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ], style: .expandable),
            .toggleableRow(title: "Real", contents: [
                "\(UIDevice.current.realFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(realFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(realFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(realFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ], style: .expandable),
        ]))

        rows.append(.toggleableRow(title: "Volume Capacity", contents: [
            "\(UIDevice.current.volumeCapacityInBytes) bytes",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0)) kB",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0 / 1000.0)) MB",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
        ]))
        rows.append(.toggleableRow(title: "Total Disk Space", contents: [
            "\(UIDevice.current.totalDiskSpaceInBytes) bytes",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0)) kB",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
        ]))
        rows.append(.row(title: "Supports Multitasking", content: UIDevice.current.isMultitaskingSupported ? "Yes" : "No"))

        if let bootTime = UIDevice.current.boottime {
            rows.append(.row(title: "Boot time", content: "\(bootTime)"))
            rows.append(.row(title: "Total Uptime", content: "\(UIDevice.current.uptime)"))
        }

        if UIDevice.current.batteryLevel >= 0, UIDevice.current.batteryState != .unknown, UIDevice.current.isBatteryMonitoringEnabled {
            rows.append(.row(title: "Battery Level", content: "\(UIDevice.current.batteryLevel * 100)%"))
            rows.append(.row(title: "Battery State", content: "\(UIDevice.current.batteryState.description ?? "?")"))
        } else {
            rows.append(.row(title: "Battery", content: "Battery monitoring is not enabled"))
        }

        rows.append(.row(title: "Device", content: "\(Device.current.safeDescription)"))
        rows.append(.row(title: "Supports 3D Touch", content: Device.current.has3dTouchSupport ? "Yes" : "No"))
        rows.append(.row(title: "Has Biometric Sensor", content: Device.current.hasBiometricSensor ? "Yes" : "No"))
        rows.append(.row(title: "Diagonal Length", content: "\(Device.current.diagonal) inches"))
        rows.append(.row(title: "Brightness", content: "\(Device.current.screenBrightness)%"))
        rows.append(.row(title: "Has Lidar", content: Device.current.hasLidarSensor ? "Yes" : "No"))
        rows.append(.row(title: "Has Camera", content: Device.current.hasCamera ? "Yes" : "No"))
        rows.append(.row(title: "Has Wide Camera", content: Device.current.hasWideCamera ? "Yes" : "No"))
        rows.append(.row(title: "Has Sensor Housing", content: Device.current.hasSensorHousing ? "Yes" : "No"))
        rows.append(.row(title: "Has Telephoto Camera", content: Device.current.hasTelephotoCamera ? "Yes" : "No"))
        rows.append(.row(title: "Has Ultrawide Camera", content: Device.current.hasUltraWideCamera ? "Yes" : "No"))
        rows.append(.row(title: "Has Rounded Display Corners", content: Device.current.hasRoundedDisplayCorners ? "Yes" : "No"))
    }
}
