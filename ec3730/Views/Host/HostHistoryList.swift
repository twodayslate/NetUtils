import SwiftUI

import AddressURL

struct HostHistoryList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var mode: EditMode = .inactive
    @FetchRequest(fetchRequest: HostDataGroup.fetchAllRequest()) var entries: FetchedResults<HostDataGroup>
    @State var isPresentigDeleteConfirm = false

    func heading(_ url: URL) -> String {
        if url.isEmail {
            return "\(url.emailAddress ?? "Unknown address")"
        }

        return "\(url.host ?? "Unknown host")"
    }

    var body: some View {
        VStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink(
                        destination: HostResult(entry),
                        label: {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(heading(entry.url)).bold()
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(entry.date.formatted())")
                                        Spacer()
                                    }
                                }

                                Spacer()
                                Text("\(entry.results.count) Results")
                            }
                        }
                    )
                }.onDelete(perform: deleteItems)
            }.listStyle(PlainListStyle()).navigationTitle("History").toolbar {
                #if os(iOS)
                    EditButton()
                #endif
            }.toolbar { ToolbarItem(placement: .bottomBar, content: {
                if mode == .active, entries.count > 1 {
                    Button {
                        isPresentigDeleteConfirm.toggle()
                    } label: {
                        Text("Delete All")
                    }
                }
            }) }.confirmationDialog("Are you sure?",
                                    isPresented: $isPresentigDeleteConfirm, titleVisibility: .visible) {
                Button("Delete all \(entries.count) items?", role: .destructive) {
                    deleteAllItems()
                }
            } message: {
                Text("You cannot undo this action")
            }
        }.environment(\.editMode, $mode)
    }

    private func deleteItems(offsets: IndexSet) {
        viewContext.perform {
            withAnimation {
                offsets.map { entries[$0] }.forEach(viewContext.delete)
                _ = try? viewContext.save()
            }
        }
    }

    private func deleteAllItems() {
        viewContext.perform {
            withAnimation {
                for object in entries {
                    viewContext.delete(object)
                    try? viewContext.save()
                    mode = .inactive
                }
            }
        }
    }
}
