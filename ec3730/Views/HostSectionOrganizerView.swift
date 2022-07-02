import SwiftUI

@available(iOS 15.0, *)
struct HostSectionOrganizerView: View {
    @EnvironmentObject var model: HostViewModel

    @Environment(\.editMode) var mode

    var body: some View {
        List {
            Section(header:
                Text("Visible")
            ) {
                ForEach(model.sections) { section in
                    Text("\(section.sectionModel.service.name)")
                }.onMove { indexSet, offset in
                    print(indexSet, indexSet.first ?? "", offset)
                    withAnimation {
                        self.model.objectWillChange.send()
                        self.model.sections.move(fromOffsets: indexSet, toOffset: offset)
                    }
                }
                // would be great if instead of delete it said hide
                .onDelete { indexSet in
                    print(indexSet, indexSet.first ?? "")
                    if let index = indexSet.first {
                        let section = model.sections[index]
                        withAnimation {
                            self.model.hidden.append(section.sectionModel.service.name)
                        }
                    }
                }
            }

            if self.mode?.wrappedValue.isEditing ?? true || !model.hidden.isEmpty {
                Section(header: Text("Hidden")) {
                    ForEach(model.hidden, id: \.self) { section in
                        Text(section)
                    }
                    // would be great if instead of delete it said
                    // unhide or show
                    .onDelete { indexSet in
                        if let index = indexSet.first {
                            let section = model.hidden[index]
                            withAnimation {
                                self.model.hidden.removeAll(where: { $0 == section })
                            }
                        }
                    }
                }
            }

        }.toolbar {
            EditButton()
        }.navigationTitle("Section Order")
    }
}

@available(iOS 15.0, *)
struct HostSectionOrganizerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HostSectionOrganizerView()
            }
        }.previewLayout(.sizeThatFits)
    }
}
