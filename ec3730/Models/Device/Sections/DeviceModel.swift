import Combine
import DeviceKit
import MachO
import SwiftUI

class DeviceModel: DeviceInfoSectionModel {
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
