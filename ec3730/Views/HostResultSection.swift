import Combine
import Foundation
import SwiftUI

@available(iOS 15.0, *)
/// this is very similiar to \ref HostViewSection
/// it doesn't have move up/down or hide since these are saved in core data and no point in hiding
struct HostResultSection: View, Equatable, Identifiable, Hashable {
    static func == (lhs: HostResultSection, rhs: HostResultSection) -> Bool {
        lhs.sectionModel.service.name == rhs.sectionModel.service.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sectionModel.service.name)
    }

    @AppStorage var isExpanded: Bool
    @State var shouldShare: Bool = false
    @State var focused: Bool = false

    @ObservedObject var sectionModel: HostSectionModel

    init(data: HostSectionModel) {
        sectionModel = data
        _isExpanded = AppStorage(wrappedValue: true, "\(Self.self).result.isExpanded." + data.service.name)
    }

    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded,
                          content: {
                              LazyVStack(alignment: .leading, spacing: 0) {
                                  ForEach(self.sectionModel.content) { row in
                                      row
                                  }

                              }.listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)).background(Color(UIColor.systemBackground))
                          },
                          label: {
                              HStack(alignment: .center) {
                                  Text(self.sectionModel.service.name).font(.headline).padding()
                                  Spacer()
                              }
                          })
                          .background(Color(UIColor.systemGroupedBackground))
                          .contextMenu(menuItems: {
                              Button(action: {
                                  withAnimation {
                                      self.isExpanded.toggle()
                                  }
                              }, label: {
                                  Label(self.isExpanded ? "Collapse" : "Expand", systemImage: self.isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                              })

                              if !sectionModel.content.isEmpty {
                                  Button(action: {
                                      withAnimation {
                                          self.focused.toggle()
                                      }
                                  }, label: {
                                      Label("Focus", systemImage: "rectangle.and.text.magnifyingglass")
                                  })
                              }

                              Divider()
                              Button(action: {
                                  UIPasteboard.general.string = self.sectionModel.dataToCopy
                              }, label: {
                                  Label("Copy", systemImage: "doc.on.doc")
                              }).disabled(self.sectionModel.dataToCopy == nil)
                              Button(action: { self.shouldShare.toggle() }, label: {
                                  Label("Share", systemImage: "square.and.arrow.up")
                              }).disabled(self.sectionModel.dataToCopy == nil)
                          })
                          .sheet(isPresented: $shouldShare, content: {
                              ShareSheetView(activityItems: [self.sectionModel.dataToCopy ?? "Error"])
                          })
                          .sheet(isPresented: $focused, content: {
                              if let latestQueriedUrl = sectionModel.latestQueriedUrl, let latestDate = sectionModel.latestQueryDate {
                                  HostViewSectionFocusView(model: sectionModel, url: latestQueriedUrl, date: latestDate)
                              } else {
                                  EZPanel(content: {
                                      ScrollView {
                                          HostViewSectionContent(sectionModel: sectionModel, canQuery: true)
                                      }
                                      .navigationTitle(sectionModel.service.name)
                                      .navigationBarTitleDisplayMode(.inline)
                                  })
                              }
                          })
    }

    var id: String {
        sectionModel.service.name
    }
}
