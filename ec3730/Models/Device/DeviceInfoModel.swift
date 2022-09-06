import Combine
import Foundation

/*
 case 1: return "Memory"
 case 2: return "JavaScriptCore"
 case 3: return "Fingerprints"
 case 4:
     return "Cellular Providers"
 */

class DeviceInfoModel: ObservableObject {
    @Published var sections = [DeviceInfoSectionModel]()

    init() {
        Task { @MainActor in
            sections.append(UIDeviceInfoModel())
            sections.append(ProcessInfoModel())
            sections.append(MemoryInfoModel())
            sections.append(JavaScriptInfoModel())
            sections.append(CarrierInfoModel())
            sections.append(FingerprintInfoModel())
            sections.append(DataUsageInfoModel())
            self.reload()
        }
    }

    @MainActor func reload() {
        objectWillChange.send()
        sections.forEach { section in
            section.objectWillChange.send()
            section.reload()
        }
    }

    @MainActor func reloadFingerprints() {
        guard let finger = sections.first(where: { $0 as? FingerprintInfoModel != nil }) as? FingerprintInfoModel else {
            return
        }
        objectWillChange.send()
        finger.objectWillChange.send()
        finger.reload()
    }

    @MainActor func attachFingerprint(model: FingerPrintModel) {
        guard let finger = sections.first(where: { $0 as? FingerprintInfoModel != nil }) as? FingerprintInfoModel else {
            return
        }
        objectWillChange.send()
        model.parent = self
        finger.attachModel(model: model)
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1000)
            reload()
        }
    }
}
