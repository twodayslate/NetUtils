import SwiftUI

struct HostHistoryList: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(fetchRequest: HostDataGroup.fetchAllRequest()) var entries: FetchedResults<HostDataGroup>

    var body: some View {
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
    }

    private func deleteItems(offsets: IndexSet) {
        viewContext.perform {
            withAnimation {
                offsets.map { entries[$0] }.forEach(viewContext.delete)

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}
