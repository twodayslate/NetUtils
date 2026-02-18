import Combine
import Foundation
import SwiftUI

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
    /// easy way to force get changes instead of having sectionmodel bubble them up
    /// correctly
    @ObservedObject var storeModel: StoreKitModel

    @State var identifiersIds = [String]()

    @MainActor
    var canQuery: Bool {
        if let storeModel = sectionModel.storeModel {
            return storeModel.owned || sectionModel.dataFeed.userKey != nil
        }
        return true
    }

    init(model: HostViewModel, sectionModel: HostSectionModel) {
        self.model = model
        self.sectionModel = sectionModel
        storeModel = sectionModel.storeModel ?? StoreKitModel(defaultId: "", ids: [])
        _isExpanded = AppStorage(wrappedValue: true, "\(Self.self).isExpanded." + sectionModel.service.name)
    }

    var shouldDisable: Bool {
        sectionModel.content.isEmpty && canQuery
    }

    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded,
                          content: {
                              HostViewSectionContent(sectionModel: sectionModel, canQuery: canQuery)
                                  .cornerRadius(6)
                          },
                          label: {
                              HStack(alignment: .center) {
                                  Text(sectionModel.service.name).font(.headline).padding()
                                  Spacer()
                              }
                          })
                          .disabled(shouldDisable)
                          .onAppear {
                              // update purchase state
                              Task {
                                  try? await sectionModel.storeModel?.update()
                              }
                          }
                          .background(Color(UIColor.systemGroupedBackground))
                          .contextMenu(menuItems: {
                              Button(action: {
                                  withAnimation {
                                      isExpanded.toggle()
                                  }
                              }, label: {
                                  Label(isExpanded ? "Collapse" : "Expand", systemImage: isExpanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                              })

                              if self != model.sections.first, let index = model.sections.firstIndex(of: self) {
                                  Button(action: {
                                      withAnimation {
                                          model.sections.swapAt(index, index.advanced(by: -1))
                                      }
                                  }, label: {
                                      Label("Move Up", systemImage: "arrow.up.to.line")
                                  })
                              }
                              if self != model.sections.last, let index = model.sections.firstIndex(of: self) {
                                  Button(action: {
                                      withAnimation {
                                          model.objectWillChange.send()
                                          model.sections.swapAt(index, index.advanced(by: 1))
                                      }
                                  }, label: {
                                      Label("Move Down", systemImage: "arrow.down.to.line")
                                  })
                              }
                              Button(action: {
                                  withAnimation {
                                      if !model.hidden.contains(sectionModel.service.name) {
                                          model.hidden.append(contentsOf: [sectionModel.service.name])
                                      }
                                  }
                              }, label: {
                                  Label("Hide", systemImage: "eye.slash")
                              })
                              if !sectionModel.content.isEmpty, canQuery {
                                  Button(action: {
                                      withAnimation {
                                          focused.toggle()
                                      }
                                  }, label: {
                                      Label("Focus", systemImage: "rectangle.and.text.magnifyingglass")
                                  })
                              }
                              Divider()
                              Button(action: {
                                  UIPasteboard.general.string = sectionModel.dataToCopy
                              }, label: {
                                  Label("Copy", systemImage: "doc.on.doc")
                              }).disabled(sectionModel.dataToCopy == nil)
                              Button(action: { shouldShare.toggle() }, label: {
                                  Label("Share", systemImage: "square.and.arrow.up")
                              }).disabled(sectionModel.dataToCopy == nil)
                          })
                          .sheet(isPresented: $shouldShare, content: {
                              ShareSheetView(activityItems: [sectionModel.dataToCopy ?? "Error"])
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
