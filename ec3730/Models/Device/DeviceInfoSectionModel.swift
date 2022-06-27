import SwiftUI

class DeviceInfoSectionModel: ObservableObject, Identifiable {
    var title: String = ""
    @MainActor @Published var enabled: Bool = false
    @MainActor @Published var rows = [CopyCellView]()

    @MainActor func reload() {}
}
