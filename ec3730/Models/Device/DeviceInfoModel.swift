import Combine
import Foundation

/*
 case 1: return "Memory"
 case 2: return "JavaScriptCore"
 case 3: return "Fingerprints"
 case 4:
     return "Cellular Providers"
 */

@MainActor
class DeviceInfoModel: ObservableObject {
    @Published var sections: [DeviceInfoSectionModel] = [
        UIDeviceInfoModel(),
        ProcessInfoModel(),
        MemoryInfoModel(),
        JavaScriptInfoModel(),
        CarrierInfoModel(),
        FingerprintInfoModel(),
        DataUsageInfoModel(),
    ]

    func reload() async {
        objectWillChange.send()
        for section in sections {
            section.objectWillChange.send()
            await section.reload()
        }
    }

    func reloadFingerprints() async {
        guard let finger = sections.first(where: { $0 as? FingerprintInfoModel != nil }) as? FingerprintInfoModel else {
            return
        }
        objectWillChange.send()
        finger.objectWillChange.send()
        await finger.reload()
    }

    func attachFingerprint(model: FingerPrintModel) async {
        guard let finger = sections.first(where: { $0 as? FingerprintInfoModel != nil }) as? FingerprintInfoModel else {
            return
        }
        objectWillChange.send()
        model.parent = self
        await finger.attachModel(model: model)
    }
}
