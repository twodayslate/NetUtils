import SwiftUI

struct DeviceInfoSectionView: View {
    @ObservedObject var section: DeviceInfoSectionModel
    @AppStorage private var isExpanded: Bool
    @State private var focused = false

    init(section: DeviceInfoSectionModel) {
        _section = ObservedObject(wrappedValue: section)
        _isExpanded = AppStorage(wrappedValue: true, "\(section.title).deviceinfo.isExpanded")
    }

    var body: some View {
        Group {
            if section.enabled {
                FSDisclosureGroup(isExpanded: $isExpanded, content: {
                    VStack(spacing: 0) {
                        ForEach(Array(section.rows.enumerated()), id: \.offset) { _, row in
                            row
                        }
                    }
                    .cornerRadius(6)
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
                            isExpanded.toggle()
                        }
                    }, label: {
                        Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                    })
                    Button(action: {
                        withAnimation {
                            focused.toggle()
                        }
                    }, label: {
                        Label("Focus", systemImage: "rectangle.and.text.magnifyingglass")
                    })
                }
                .sheet(isPresented: $focused, content: {
                    EZPanel(content: {
                        ScrollView {
                            ForEach(Array(section.rows.enumerated()), id: \.offset) { _, row in
                                row
                            }
                        }
                        .navigationTitle(section.title)
                        .navigationBarTitleDisplayMode(.inline)
                    })
                })
            }
        }
    }
}
