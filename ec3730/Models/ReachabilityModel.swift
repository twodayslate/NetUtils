import CoreLocation
import Foundation
import NetUtils
import Reachability
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import UIKit

class ReachabilityModel: NSObject, ObservableObject {
    var reachability = Reachability.shared

    @Published var connection: Reachability.Connection = .unavailable
    @Published var authorization: CLAuthorizationStatus = .notDetermined

    @Published var ssid: String?
    @Published var wifiInterface: String?
    @Published var wifiInterfaceInfo: [String: Any?]?

    @Published var interfaces = [Interface]()

    let locationManager = CLLocationManager()

    var connectionAvailable: Bool {
        connection == .wifi || connection == .cellular
    }

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: Reachability.shared)
        do {
            try Reachability.shared.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }

    @objc private func reachabilityChanged(note _: Notification) {
        DispatchQueue.main.async {
            self.update()
        }
    }

    @objc @MainActor private func update() {
        objectWillChange.send()
        interfaces = Interface.allInterfaces()
        connection = reachability.connection
        ssid = nil
        wifiInterface = nil
        wifiInterfaceInfo = nil

        switch connection {
        case .wifi:
            let status = locationManager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                if let (optionalInterface, optionalSsid, optionalInfo) = WiFi.ssidInfo() {
                    ssid = optionalSsid
                    wifiInterface = optionalInterface
                    wifiInterfaceInfo = optionalInfo
                }
            } else {
                // XXX: add information prompt before the actual request
                locationManager.requestWhenInUseAuthorization()
                // XXX: This goes away after a second or two?... why?
            }
        default:
            break
        }
    }

    @MainActor func reload() {
        update()
    }
}

extension ReachabilityModel: CLLocationManagerDelegate {
    func locationManager(_: CLLocationManager, didChangeAuthorization auth: CLAuthorizationStatus) {
        switch auth {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            Task {
                await update()
            }
        default:
            break
        }
    }
}
