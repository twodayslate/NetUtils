import Combine
import DeviceKit
import SwiftUI

class FingerprintInfoModel: DeviceInfoSectionModel {
    var models = [FingerPrintModel]()

    override init() {
        super.init()
        title = "Fingerprints"

        Task { @MainActor in
            reload()
        }
    }

    @MainActor func attachModel(model: FingerPrintModel) {
        if !models.contains(model) {
            models.append(model)
            reload()
        }
    }

    @MainActor override func reload() {
        enabled = models.count > 0
        rows.removeAll()

        for (i, model) in models.enumerated() {
            rows.append(CopyCellView(title: "Fingerprint \(i)", content: model.fingerprint ?? "-"))
        }
    }
}
