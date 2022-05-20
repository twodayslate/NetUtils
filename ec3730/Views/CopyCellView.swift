import SwiftUI

protocol CopyCellProtocol: View, Hashable, Identifiable {
    var contentsToShare: String { get }
}

struct CopyCellRow: Identifiable, Hashable, Codable {
    var id: Int {
        hashValue
    }

    var title: String?
    var content: String
}

@available(iOS 15.0, *)
struct CopyCellView: CopyCellProtocol {
    var id: String {
        contentsToShare + "\(hashValue)"
    }

    static func == (lhs: CopyCellView, rhs: CopyCellView) -> Bool {
        lhs.title == rhs.title && lhs.content == rhs.content
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(content)
    }

    var title: String
    var content: String?
    var rows: [CopyCellRow]?

    @State var shouldShare: Bool = false

    var contentsToShare: String {
        if let content = content {
            let dict = [title: content]
            guard let data = try? JSONSerialization.data(withJSONObject: dict), let string = String(data: data, encoding: .utf8) else {
                return "{}"
            }

            return string
        }

        if let rows = rows {
            let dict = [title: rows]
            guard let data = try? JSONEncoder().encode(dict), let string = String(data: data, encoding: .utf8) else {
                return "{}"
            }

            return string
        }

        return "{}"
    }

    @State var expanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let content = self.content {
                HStack(alignment: .center) {
                    Text(self.title)
                    Spacer()
                    Text(content).foregroundColor(.gray)
                }.padding()
            } else if let rows = self.rows {
                DisclosureGroup(isExpanded: $expanded, content: {
                    ForEach(rows, id: \.self) { row in
                        HStack(alignment: .center) {
                            if let title = row.title {
                                Text(title)
                            }
                            Spacer()
                            Text(row.content)
                        }.padding([.leading, .trailing]).padding(.top, 4)
                    }
                }, label: {
                    Text(self.title)
                }).padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .contextMenu(menuItems: {
            Button(action: {
                UIPasteboard.general.string = content
            }, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })
            Button(action: { self.shouldShare.toggle() }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
        }).sheet(isPresented: $shouldShare, content: {
            ShareSheetView(activityItems: [self.contentsToShare])
        })
    }
}

@available(iOS 15.0, *)
struct CopyCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CopyCellView(title: "Title", content: "Detail")
            CopyCellView(title: "Test", rows: [CopyCellRow(title: "", content: "whatever")])
            CopyCellView(title: "Test", rows: [CopyCellRow(title: "", content: "whatever"), CopyCellRow(title: "", content: "whatever"), CopyCellRow(title: "", content: "whatever2"), CopyCellRow(title: "", content: "whatever3")])
            CopyCellView(title: "Test", rows: [CopyCellRow(title: "t1", content: "whatever"), CopyCellRow(title: "t2", content: "whatever2")])
        }.previewLayout(.sizeThatFits)
    }
}
