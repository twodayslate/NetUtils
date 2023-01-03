import SwiftUI

struct CopyCellTypeView: View {
    var type: CopyCellType
    var backgroundColor = Color(UIColor.systemBackground)
    @State private var shouldShare: Bool = false
    @State var expanded: Bool = true

    @ViewBuilder
    var typeView: some View {
        switch type {
        case let .row(title: title, content: content, style: style):
            CopyCellSingleItemRowView(title: title, content: content, style: style)
        case let .toggleableRow(title: title, contents: contents, style: style):
            CopyCellToggleableItemRowView(title: title, contents: contents, style: style)
        case let .multiple(title: title, contents: content):
            CopyCellMultipleTypesView(title: title, contents: content, expanded: $expanded)
        case let .custom(shareable: _, content: content):
            content
        case let .content(value, style: style):
            CopyCellContentView(content: value, style: style)
        }
    }

    var body: some View {
        typeView
            .background(backgroundColor)
            .contextMenu(menuItems: {
                if type.isCopyable {
                    Button(action: {
                        switch type.shareable {
                        case is String:
                            UIPasteboard.general.string = type.shareable as? String
                        case is [String]:
                            UIPasteboard.general.strings = type.shareable as? [String]
                        case is UIImage:
                            UIPasteboard.general.image = type.shareable as? UIImage
                        case is [UIImage]:
                            UIPasteboard.general.images = type.shareable as? [UIImage]
                        case is UIColor:
                            UIPasteboard.general.color = type.shareable as? UIColor
                        case is [UIColor]:
                            UIPasteboard.general.colors = type.shareable as? [UIColor]
                        case is URL:
                            UIPasteboard.general.url = type.shareable as? URL
                        case is [URL]:
                            UIPasteboard.general.urls = type.shareable as? [URL]
                        default:
                            break
                        }
                    }, label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    })
                }
                Button(action: {
                    self.shouldShare.toggle()

                }, label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                })

                if type.isExpandable {
                    Button {
                        expanded.toggle()
                    } label: {
                        Label(expanded ? "Collapse" : "Expand", systemImage: expanded ? "rectangle.compress.vertical" : "rectangle.expand.vertical")
                    }
                }
            }).sheet(isPresented: $shouldShare, content: {
                ShareSheetView(activityItems: [type.shareable])
            })
    }
}
