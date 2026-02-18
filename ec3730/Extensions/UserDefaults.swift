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
            static var hideScrollbars: String {
                "hide_scrollbars"
            }

            /// Key to enable/disable resource thumbnails
            static var resourceThumbnails: String {
                "resource_thumbnails"
            }

            /// Key to enable/disable the calculator save result animation
            static var saveCalculatorResultAnimation: String {
                "save_result_animation"
            }

            /// Key to enable/disable smart rotation lock for media
            static var smartRotationLock: String {
                "landscape_videos"
            }

            static func keyFor(dataFeed: DataFeed) -> String {
                "feed." + dataFeed.name.lowercased().replacingOccurrences(of: " ", with: ".") + ".key"
            }

            static func keyFor(service: Service) -> String {
                "service." + service.name.lowercased().replacingOccurrences(of: " ", with: ".") + ".usage.key"
            }
        }
    }
}
