import SwiftUI

struct HostViewSectionFocusView: View {
    @ObservedObject var model: HostSectionModel
    var url: URL
    var date: Date
    var body: some View {
        EZPanel {
            VStack(spacing: 0) {
                ScrollView {
                    HostViewSectionContent(sectionModel: model, canQuery: true)
                }.safeAreaInset(edge: .bottom) {
                    HostBarView(url: url, date: date)
                }
            }
            .navigationTitle(model.service.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
