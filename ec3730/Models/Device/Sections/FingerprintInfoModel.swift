import Combine
import DeviceKit
import SwiftUI

class FingerprintInfoModel: DeviceInfoSectionModel {
    @MainActor var models = [FingerPrintModel]()

    override init() {
        super.init()
        title = "Fingerprints"
    }

    @MainActor func attachModel(model: FingerPrintModel) async {
        if !models.contains(model) {
            models.append(model)
            await reload()
        }
    }

    @MainActor override func reload() async {
        enabled = models.count > 0
        rows.removeAll()

        for (i, model) in models.enumerated() {
            rows.append(.row(title: "Fingerprint \(i)", content: model.fingerprint ?? "-"))
        }
    }
}
