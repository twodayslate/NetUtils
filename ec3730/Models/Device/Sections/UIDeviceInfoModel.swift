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

        rows.append(CopyCellView(title: "Disk Space Available", rows: [
            CopyCellRow(title: "Important", content: "\(UIDevice.current.importantFreeDiskSpaceInBytes) bytes"),
            CopyCellRow(title: "Opportunistic", content: "\(UIDevice.current.opportunisticFreeDiskSpaceInBytes) bytes"),
            CopyCellRow(title: "Real", content: "\(UIDevice.current.realFreeDiskSpaceInBytes) bytes"),
        ]))

        rows.append(CopyCellView(title: "Volume Capacity", content: "\(UIDevice.current.volumeCapacityInBytes) bytes"))
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
