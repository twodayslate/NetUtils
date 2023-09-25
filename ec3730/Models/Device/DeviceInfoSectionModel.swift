import SwiftUI

class DeviceInfoSectionModel: ObservableObject, Identifiable {
    var title: String = ""
    @MainActor @Published var enabled: Bool = false
    @MainActor @Published var rows = [CopyCellType]()

    @MainActor func reload() async {}
}
