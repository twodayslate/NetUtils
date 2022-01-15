import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Combine
import Introspect
import InterposeKit

struct FSDisclosureGroup<Label, Content>: View where Label: View, Content: View {
  @Binding var isExpanded: Bool
  var content: () -> Content
  var label: () -> Label

  var body: some View {
    VStack(alignment: .leading, spacing: 0.0) {
        Button(action: {
            withAnimation {
                self.isExpanded.toggle()
            }
        }, label: {
            HStack(alignment: .center) {
                label()
                Image(systemName: "chevron.down").rotationEffect(self.isExpanded ? .degrees(0.0) : .degrees(-90.0)).padding()
            }
        })
        
        if self.isExpanded {
            content()
        }
    }
  }
}

@available(iOS 15.0, *)
struct HostView: View {
    @EnvironmentObject var model: HostViewModel
    
    @State var dragging: HostViewSection? = nil
    
    @State var text = ""
    @State var dismissKeyboard = UUID()
    var defaultUrl = "google.com"
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(self.model.sections, id: \.self.id) { section in
                                section.onDrag {
                                    self.dragging = section

                                    return NSItemProvider(item: String(section.id) as NSString, typeIdentifier: "com.twodayslate.netutils.hostview.header")
                                }
                                .onDrop(of: ["com.twodayslate.netutils.hostview.header"], delegate: HostDragRelocateDelegate(item: section, listData: $model.sections, current: $dragging))
                            }
                        }.animation(.default, value: model.sections)
                    }
                    VStack(alignment: .leading, spacing: 0.0) {
                        Divider()
                        HStack(alignment: .center) {
                            // it would be great if this could be a .bottomBar toolbar but it is too buggy
                            TextField(self.defaultUrl, text: $text,  onCommit: { Task {
                                await self.query()
                            }
                            }).id(dismissKeyboard).disableAutocorrection(true).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.URL).padding(.leading, geometry.safeAreaInsets.leading)
                            if self.model.isQuerying {
                                Button("Cancel", action: {
                                    self.cancel()
                                }).padding(.trailing, geometry.safeAreaInsets.trailing)
                            } else {
                                Button("Lookup", action: {
                                    Task {
                                   await self.query()
                                    }
                                }).padding(.trailing, geometry.safeAreaInsets.trailing)
                            }
                        }.padding(.horizontal).padding([.vertical], 6)
                    }.background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).ignoresSafeArea(.all, edges: .horizontal)).ignoresSafeArea()
                }.navigationBarTitle("Host Information", displayMode: .inline)
            }
        }
    }
    
    func cancel() {
        self.model.cancel()
    }
    
    // iOS 15 todo: https://www.hackingwithswift.com/quick-start/swiftui/how-to-take-action-when-the-user-submits-a-textfield
    func query() async {
        var url = URL(string: self.text)
        if (url == nil) && self.text.isEmpty {
            url = URL(string: self.defaultUrl)
        }
        await self.model.query(url: url, completion: {
            
        })
    }

}

@available(iOS 15.0, *)
struct HostDragRelocateDelegate: DropDelegate {
    let item: HostViewSection
    @Binding var listData: [HostViewSection]
    @Binding var current: HostViewSection?

    func dropEntered(info: DropInfo) {
        print("drop entered", info.location, current?.id ?? "none", item.id)
        if current == nil {
            current = item
        }
        
        guard let current = current else {
            return
        }
        
        if item.id != current.id {
            let from = listData.firstIndex(of: current)!
            let to = listData.firstIndex(of: item)!
            if listData[to] != current {
                listData.move(fromOffsets: IndexSet(integer: from),
                    toOffset: to > from ? to + 1 : to)
            }
        }
        print("drop entered done")
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        print("perform drop", current?.id ?? "none")
        self.current = nil
        return true
    }
}

@available(iOS 15.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HostView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
