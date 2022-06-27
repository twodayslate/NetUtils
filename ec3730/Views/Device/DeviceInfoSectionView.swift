import SwiftUI

struct DeviceInfoSectionView: View {
    var section: DeviceInfoSectionModel
    @AppStorage var isExpanded: Bool
    @State var focused = false

    init(section: DeviceInfoSectionModel) {
        self.section = section
        _isExpanded = AppStorage(wrappedValue: true, "\(section.title).deviceinfo.isExpanded")
    }

    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded, content: {
            ForEach(section.rows) { row in
                row
            }
        }, label: {
            HStack(alignment: .center) {
                Text(section.title).font(.headline).padding()
                Spacer()
            }
        })
        .background(Color(UIColor.systemGroupedBackground))
        .contextMenu {
            Button(action: {
                withAnimation {
                    self.isExpanded.toggle()
                }
            }, label: {
                Label(self.isExpanded ? "Collapse" : "Expand", systemImage: self.isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
            })
            Button(action: {
                withAnimation {
                    self.focused.toggle()
                }
            }, label: {
                Label("Focus", systemImage: "rectangle.and.text.magnifyingglass")
            })
        }
        .sheet(isPresented: $focused, content: {
            EZPanel(content: {
                ScrollView {
                    ForEach(section.rows) { row in
                        row
                    }
                }
                .navigationTitle(section.title)
                .navigationBarTitleDisplayMode(.inline)
            })
        })
    }
}
