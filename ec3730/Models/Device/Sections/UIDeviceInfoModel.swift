import Combine
import DeviceKit
import SwiftUI

/// Device information from ``UIDevice`` and ``DeviceKit``
class UIDeviceInfoModel: DeviceInfoSectionModel {
    override init() {
        super.init()
        title = "Device Information"

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

        // "kB", "MB", "GB", "TB", "PB", "EB", "ZB", and "YB" for SI units (base 1000).
        // "kiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", and "YiB" for binary units (base 1024).

        rows.append(CopyCellView(title: "Disk Space Available", rows: [
            CopyCellRow(title: "Important", contents: [
                "\(UIDevice.current.importantFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(UIDevice.current.importantFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(UIDevice.current.importantFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(UIDevice.current.importantFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ]),
            CopyCellRow(title: "Opportunistic", contents: [
                "\(UIDevice.current.opportunisticFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(UIDevice.current.opportunisticFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(UIDevice.current.opportunisticFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(UIDevice.current.opportunisticFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ]),
            CopyCellRow(title: "Real", contents: [
                "\(UIDevice.current.realFreeDiskSpaceInBytes) bytes",
                "\(String(format: "%0.2f", Double(UIDevice.current.realFreeDiskSpaceInBytes) / 1000.0)) kB",
                "\(String(format: "%0.2f", Double(UIDevice.current.realFreeDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
                "\(String(format: "%0.2f", Double(UIDevice.current.realFreeDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
            ]),
        ]))

        rows.append(CopyCellView(title: "Volume Capacity", contents: [
            "\(UIDevice.current.volumeCapacityInBytes) bytes",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0)) kB",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0 / 1000.0)) MB",
            "\(String(format: "%0.2f", Double(UIDevice.current.volumeCapacityInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
        ]))
        rows.append(CopyCellView(title: "Total Disk Space", contents: [
            "\(UIDevice.current.totalDiskSpaceInBytes) bytes",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0)) kB",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0 / 1000.0)) MB",
            "\(String(format: "%0.2f", Double(UIDevice.current.totalDiskSpaceInBytes) / 1000.0 / 1000.0 / 1000.0)) GB",
        ]))
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

        rows.append(CopyCellView(title: "Device", content: "\(Device.current.safeDescription)"))
        rows.append(CopyCellView(title: "Supports 3D Touch", content: Device.current.has3dTouchSupport ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Biometric Sensor", content: Device.current.hasBiometricSensor ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Diagonal Length", content: "\(Device.current.diagonal) inches"))
        rows.append(CopyCellView(title: "Brightness", content: "\(Device.current.screenBrightness)%"))
        rows.append(CopyCellView(title: "Has Lidar", content: Device.current.hasLidarSensor ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Camera", content: Device.current.hasCamera ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Wide Camera", content: Device.current.hasWideCamera ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Sensor Housing", content: Device.current.hasSensorHousing ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Telephoto Camera", content: Device.current.hasTelephotoCamera ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Ultrawide Camera", content: Device.current.hasUltraWideCamera ? "Yes" : "No"))
        rows.append(CopyCellView(title: "Has Rounded Display Corners", content: Device.current.hasRoundedDisplayCorners ? "Yes" : "No"))
    }
}
