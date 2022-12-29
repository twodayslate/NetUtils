import SwiftUI

public protocol CopyCellProtocol: View, Hashable, Identifiable {
    associatedtype T
    var contentsToShare: T { get }
}

struct CopyCellRow: Identifiable, Hashable, Codable {
    var id: Int {
        hashValue
    }

    var title: String?
    var content: String?
    var contents: [String]?
}

@available(iOS 15.0, *)
struct CopyCellView<T>: CopyCellProtocol {
    var id: String {
        if let content = contentsToShare as? String {
            return content + "\(hashValue)"
        } else {
            return "\(hashValue)"
        }
    }

    static func == (lhs: CopyCellView, rhs: CopyCellView) -> Bool {
        lhs.title == rhs.title // && lhs.content == rhs.content
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        // hasher.combine(content)
    }

    var title: String
    var content: Any?
    var contents: [String]?
    var rows: [CopyCellRow]?
    var backgroundColor = Color(UIColor.systemBackground)
    var withChevron = false

    @State var shouldShare: Bool = false

    var contentsToShare: T {
        if let content = content {
            let dict = [title: content]
            guard let data = try? JSONSerialization.data(withJSONObject: dict), let string = String(data: data, encoding: .utf8) else {
                return "{}" as! T
            }

            return string as! T
        }

        if let rows = rows {
            let dict = [title: rows]
            guard let data = try? JSONEncoder().encode(dict), let string = String(data: data, encoding: .utf8) else {
                return "{}" as! T
            }

            return string as! T
        }

        return "{}" as! T
    }

    @State var expanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let content = self.content {
                VStack {
                    HStack(alignment: .center) {
                        Text(self.title)
                        Spacer()
                        if let contentAsString = content as? String {
                            Text(contentAsString).foregroundColor(.gray)
                            if withChevron {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(UIColor.systemGray3))
                            }
                        }
                    }.padding()
                }
            } else if let rows = self.rows {
                DisclosureGroup(isExpanded: $expanded, content: {
                    ForEach(rows, id: \.self) { row in
                        VStack {
                            HStack(alignment: .center) {
                                if let title = row.title {
                                    Text(title)
                                }
                                Spacer()
                                if let content = row.content {
                                    Text(content)
                                }
                                if let contents = row.contents {
                                    TappedText(content: contents)
                                }
                            }.padding([.leading, .trailing]).padding(.top, 4)
                        }
                    }
                }, label: {
                    Text(self.title)
                }).padding()
            } else if let contents = contents {
                VStack {
                    HStack(alignment: .center) {
                        Text(self.title)
                        Spacer()
                        TappedText(content: contents)
                            .foregroundColor(.gray)

                        if withChevron {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(UIColor.systemGray3))
                        }
                    }.padding()
                }
            }
        }
        .background(backgroundColor)
        .contextMenu(menuItems: {
            Button(action: {
                if let contentAsString = content as? String {
                    UIPasteboard.general.string = contentAsString
                } else if let contentAsImage = content as? UIImage {
                    UIPasteboard.general.image = contentAsImage
                } else {
                    UIPasteboard.general.string = "\(content ?? "")"
                }
            }, label: {
                Label("Copy", systemImage: "doc.on.doc")
            })
            Button(action: { self.shouldShare.toggle() }, label: {
                Label("Share", systemImage: "square.and.arrow.up")
            })
            if let _ = self.rows {
                Button {
                    expanded.toggle()
                } label: {
                    Label(expanded ? "Collapse" : "Expand", systemImage: expanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                }
            }
        }).sheet(isPresented: $shouldShare, content: {
            ShareSheetView(activityItems: [self.contentsToShare])
        })
    }
}

struct ImageView: View {
    var imageVal: UIImage?
    var body: some View {
        if imageVal != nil {
            HStack {
                Spacer()
                Image(uiImage: imageVal!).padding(.trailing)
            }
        }
    }
}

struct TappedText: View {
    @State private var selectedTextIndex: Int = 0

    var content: [String]

    var body: some View {
        Text(content[selectedTextIndex])
            .onTapGesture {
                let temp = selectedTextIndex + 1

                selectedTextIndex = temp >= content.count ? 0 : temp
            }
    }
}

@available(iOS 15.0, *)
struct CopyCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CopyCellView<Any>(title: "Title", content: "Detail")
            CopyCellView<Any>(title: "Test", rows: [CopyCellRow(title: "", content: "whatever")])
            CopyCellView<Any>(title: "Test", rows: [CopyCellRow(title: "", content: "whatever"),
                                                    CopyCellRow(title: "", content: "whatever"),
                                                    CopyCellRow(title: "", content: "whatever2"),
                                                    CopyCellRow(title: "", content: "whatever3")])
            CopyCellView<Any>(title: "Test", rows: [CopyCellRow(title: "t1", content: "whatever"),
                                                    CopyCellRow(title: "t2", content: "whatever2")])
        }.previewLayout(.sizeThatFits)
    }
}
