import CoreTelephony
import SwiftUI

class CarrierInfoModel: DeviceInfoSectionModel {
    private var getProviderTask: Task<Void, Never>?
    private var networkInfo: CTTelephonyNetworkInfo?
    private var providers: [String: CTCarrier]?

    override init() {
        super.init()
        title = "Cellular Providers"

        Task {
            await reload()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name.CTServiceRadioAccessTechnologyDidChange, object: nil)
    }

    @MainActor private func setEnabled(_ completion: (@MainActor () -> Void)? = nil) {
        getProviderTask?.cancel()
        getProviderTask = Task.detached(priority: .userInitiated) {
            self.networkInfo = CTTelephonyNetworkInfo()
            self.providers = self.networkInfo?.serviceSubscriberCellularProviders

            Task { @MainActor [weak self] in
                self?.objectWillChange.send()
                self?.enabled = (self?.providers?.count ?? 0) > 0
                completion?()
            }
        }
    }

    @MainActor private func setRows() {
        rows.removeAll()

        guard enabled, let networkInfo = networkInfo, let providers = providers else {
            return
        }

        if let value = networkInfo.dataServiceIdentifier {
            rows.append(.row(title: "Data Service Identifier", content: value))
        }

        if let value = networkInfo.serviceCurrentRadioAccessTechnology {
            for item in value {
                rows.append(.row(title: "Data Service \(item.key) Radio Access Technology", content: item.value))
            }
        }

        for (i, carrier) in providers.enumerated() {
            if let name = carrier.value.carrierName {
                rows.append(.row(title: "Provider \(i) Carrier Name", content: name))
            }
            rows.append(.row(title: "Provider \(i) Service", content: carrier.key))
            rows.append(.row(title: "Provider \(i) Allows VOIP", content: carrier.value.allowsVOIP ? "Yes" : "No"))
            if let value = carrier.value.isoCountryCode {
                rows.append(.row(title: "Provider \(i) ISO Country Code", content: value))
            }
            if let value = carrier.value.mobileCountryCode {
                rows.append(.row(title: "Provider \(i) Mobile Country Code", content: value))
            }
            if let value = carrier.value.mobileNetworkCode {
                rows.append(.row(title: "Provider \(i) Mobile Network Code", content: value))
            }
        }
    }

    @objc @MainActor override func reload() {
        setEnabled { [weak self] in
            self?.setRows()
        }
    }
}
