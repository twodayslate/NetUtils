import Foundation
import SwiftUI
import Combine

@available(iOS 15.0, *)
struct HostViewSection: View, Equatable, Identifiable, Hashable {
    static func == (lhs: HostViewSection, rhs: HostViewSection) -> Bool {
        return lhs.sectionModel.service.name == rhs.sectionModel.service.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.sectionModel.service.name)
    }
        
    @AppStorage var isExpanded: Bool
    @State var shouldShare: Bool = false
    @ObservedObject var model: HostViewModel
    
    @ObservedObject var sectionModel: HostSectionModel

    init(model: HostViewModel, sectionModel: HostSectionModel){
        self.model = model
        self.sectionModel = sectionModel
        self._isExpanded = AppStorage(wrappedValue: false, "\(Self.self).isExpanded."+sectionModel.service.name)
    }
    
    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded,
            content: {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if self.sectionModel.storeModel.purchasedIdentifiers.count > 0 {
                        // Need se-0309
                        ForEach(self.sectionModel.content) { row in
                            row
                        }
                    } else {
                        PurchaseCellView(model: self.sectionModel.storeModel)
                    }
                    
                }.listRowInsets(EdgeInsets.init(top: 8, leading: 0, bottom: 8, trailing: 0)).background(Color.init(UIColor.systemBackground))
            },
            label: {
                HStack(alignment: .center) {
                    Text(self.sectionModel.service.name).font(.headline).padding()
                    Spacer()
                }
        })
        .background(Color(UIColor.systemGroupedBackground)).contextMenu(menuItems: {
            Button(action: {
                withAnimation {
                    self.isExpanded.toggle()
                }
            }, label: {
                Label(self.isExpanded ? "Collapse" : "Expand", systemImage: self.isExpanded ? "rectangle.compress.vertical": "rectangle.expand.vertical")
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
            Divider()
            Button(action: {
                UIPasteboard.general.string = self.sectionModel.dataToCopy
            }, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })
            Button(action: { self.shouldShare.toggle() }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
        })
        .sheet(isPresented: $shouldShare, content: {
            ShareSheetView(activityItems: [self.sectionModel.dataToCopy ?? "Error"])
        })
            
    }
    
    var id: String {
        self.sectionModel.service.name
    }
}
