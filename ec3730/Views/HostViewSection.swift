import Combine
import Foundation
import SwiftUI

@available(iOS 15.0, *)
struct HostViewSection: View, Equatable, Identifiable, Hashable {
    static func == (lhs: HostViewSection, rhs: HostViewSection) -> Bool {
        lhs.sectionModel.service.name == rhs.sectionModel.service.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(sectionModel.service.name)
    }

    @AppStorage var isExpanded: Bool
    @State var shouldShare: Bool = false
    @State var focused: Bool = false
    @ObservedObject var model: HostViewModel

    @ObservedObject var sectionModel: HostSectionModel
    // easy way to force get changes instead of having sectionmodel bubble them up
    // correctly
    @ObservedObject var storeModel: StoreKitModel

    @State var identifiersIds = [String]()

    @MainActor
    var canQuery: Bool {
        if let storeModel = sectionModel.storeModel {
            return (storeModel.owned || sectionModel.dataFeed.userKey != nil)
        }
        return false
    }

    init(model: HostViewModel, sectionModel: HostSectionModel) {
        self.model = model
        self.sectionModel = sectionModel
        storeModel = sectionModel.storeModel ?? StoreKitModel(defaultId: "", ids: [])
        _isExpanded = AppStorage(wrappedValue: true, "\(Self.self).isExpanded." + sectionModel.service.name)
    }

    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded,
                          content: {
                              HostViewSectionContent(sectionModel: sectionModel, canQuery: canQuery)
                          },
                          label: {
                              HStack(alignment: .center) {
                                  Text(self.sectionModel.service.name).font(.headline).padding()
                                  Spacer()
                              }
                          })
                          .onAppear {
                              // update purchase state
                              Task {
                                  try? await self.sectionModel.storeModel?.update()
                              }
                          }
                          .background(Color(UIColor.systemGroupedBackground))
                          .contextMenu(menuItems: {
                              Button(action: {
                                  withAnimation {
                                      self.isExpanded.toggle()
                                  }
                              }, label: {
                                  Label(self.isExpanded ? "Collapse" : "Expand", systemImage: self.isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                              })

                              if self != self.model.sections.first, let index = self.model.sections.firstIndex(of: self) {
                                  Button(action: {
                                      withAnimation {
                                          self.model.sections.swapAt(index, index.advanced(by: -1))
                                      }
                                  }, label: {
                                      Label("Move Up", systemImage: "arrow.up.to.line")
                                  })
                              }
                              if self != self.model.sections.last, let index = self.model.sections.firstIndex(of: self) {
                                  Button(action: {
                                      withAnimation {
                                          self.model.objectWillChange.send()
                                          self.model.sections.swapAt(index, index.advanced(by: 1))
                                      }
                                  }, label: {
                                      Label("Move Down", systemImage: "arrow.down.to.line")
                                  })
                              }
                              Button(action: {
                                  withAnimation {
                                      if !self.model.hidden.contains(self.sectionModel.service.name) {
                                          self.model.hidden.append(contentsOf: [self.sectionModel.service.name])
                                      }
                                  }
                              }, label: {
                                  Label("Hide", systemImage: "eye.slash")
                              })
                              if !sectionModel.content.isEmpty, canQuery {
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
                                          HostViewSectionContent(sectionModel: sectionModel, canQuery: canQuery)
                                      }
                                      .navigationTitle(sectionModel.service.name)
                                      .navigationBarTitleDisplayMode(.inline)
                                  })
                              }
                          })
    }

    var id: String {
        let ans = sectionModel.dataFeed.name + sectionModel.service.name + "\(canQuery.description)"
        return ans.filter { !$0.isWhitespace }
    }
}
