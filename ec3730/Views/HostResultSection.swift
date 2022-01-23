import Foundation
import SwiftUI
import Combine

@available(iOS 15.0, *)
/// this is very similiar to \ref HostViewSection
/// it doesn't have move up/down or hide since these are saved in core data and no point in hiding
struct HostResultSection: View, Equatable, Identifiable, Hashable {
    static func == (lhs: HostResultSection, rhs: HostResultSection) -> Bool {
        return lhs.sectionModel.service.name == rhs.sectionModel.service.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.sectionModel.service.name)
    }
        
    @AppStorage var isExpanded: Bool
    @State var shouldShare: Bool = false
    //@ObservedObject var model: HostViewModel
    
    @ObservedObject var sectionModel: HostSectionModel

    init(data: HostSectionModel){
        self.sectionModel = data
        self._isExpanded = AppStorage(wrappedValue: true, "\(Self.self).result.isExpanded."+data.service.name)
    }
    
    var body: some View {
        FSDisclosureGroup(isExpanded: $isExpanded,
            content: {
                
                LazyVStack(alignment: .leading, spacing: 0) {

                        ForEach(self.sectionModel.content) { row in
                            row
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
    }
    
    var id: String {
        self.sectionModel.service.name
    }
}
