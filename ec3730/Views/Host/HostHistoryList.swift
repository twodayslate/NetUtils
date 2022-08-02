import SwiftUI

struct HostHistoryList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var mode: EditMode = .inactive
    @FetchRequest(fetchRequest: HostDataGroup.fetchAllRequest()) var entries: FetchedResults<HostDataGroup>

    var body: some View {
        VStack {
            if mode == .active, entries.count > 1 {
                Button {
                    deleteAllItems()
                } label: {
                    Text("Delete All")
                }
            }
            List {
                ForEach(entries) { entry in
                    NavigationLink(
                        destination: HostResult(entry),
                        label: {
                            HStack {
                                VStack {
                                    HStack {
                                        Text("\(entry.url.host ?? "Unknown host")").bold()
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(entry.date.ISO8601Format())")
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
