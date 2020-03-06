//
//  UIDevice.swift
//  ec3730
//
//  Created by Zachary Gorak on 10/28/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    /// https://stackoverflow.com/a/47463829/193772
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }

    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    /// https://stackoverflow.com/a/47463829/193772
    var freeDiskSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            // swiftlint:disable:next line_length
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var boottime: Date? {
        var tv = timeval()
        var tvSize = MemoryLayout<timeval>.size
        let err = sysctlbyname("kern.boottime", &tv, &tvSize, nil, 0)
        guard err == 0, tvSize == MemoryLayout<timeval>.size else {
            return nil
        }
        return Date(timeIntervalSince1970: Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0)
    }

    var uptime: TimeInterval {
        guard let bootTime = self.boottime else {
            return 0
        }
        return Date().timeIntervalSince(bootTime)
    }

    var hwMachine: String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }

    var hwModel: String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &machine, &size, nil, 0)
        return String(cString: machine)
    }
}

extension UIDevice.BatteryState {
    var description: String? {
        switch self {
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        case .unknown:
            return "Unknown"
        case .unplugged:
            return "Unplugged"
        @unknown default:
            return nil
        }
    }
}

extension UIUserInterfaceIdiom {
    var description: String? {
        switch self {
        case .carPlay:
            return "CarPlay"
        case .pad:
            return "Pad"
        case .phone:
            return "Phone"
        case .tv:
            return "TV"
        case .unspecified:
            return "Unspecified"
        @unknown default:
            return nil
        }
    }
}
