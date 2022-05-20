//
//  UserDefaults.swift
//  acft
//
//  Created by Zachary Gorak on 5/30/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum NetUtils {
        enum Keys {
            public static var hideScrollbars: String { "hide_scrollbars" }
            /// Key to enable/disable resource thumbnails
            public static var resourceThumbnails: String { "resource_thumbnails" }
            /// Key to enable/disable the calculator save result animation
            public static var saveCalculatorResultAnimation: String { "save_result_animation" }
            /// Key to enable/disable smart rotation lock for media
            public static var smartRotationLock: String { "landscape_videos" }
            public static func keyFor(dataFeed: DataFeed) -> String {
                "feed." + dataFeed.name.lowercased().replacingOccurrences(of: " ", with: ".") + ".key"
            }

            public static func keyFor(service: Service) -> String {
                "service." + service.name.lowercased().replacingOccurrences(of: " ", with: ".") + ".usage.key"
            }
        }
    }
}
