import SwiftUI

enum CopyCellType: NewCopyCellProtocol {
    static func == (lhs: CopyCellType, rhs: CopyCellType) -> Bool {
        lhs.id == rhs.id
    }

    var json: [String: Any] {
        switch self {
        case let .toggleableRow(title: title, contents: contents, style: _):
            return [title: contents]
        case let .row(title: title, content: content, style: _):
            return [title: content]
        case let .multiple(title: title, contents: contents):
            return [title: contents.map(\.json)]
        case .content(let value, style: _):
            return ["String": value]
        case .custom(shareable: let shareable, content: _):
            let key = "\(type(of: shareable))"
            if let dict = shareable.dictionary {
                return dict
            } else if shareable is String {
                return [key: shareable]
            } else if let data = try? NSKeyedArchiver.archivedData(withRootObject: shareable, requiringSecureCoding: false) {
                return [key: data.base64EncodedString()]
            }
            return [:]
        }
    }

    var shareable: any Shareable {
        let dict = self.json
        guard JSONSerialization.isValidJSONObject(dict), let data = try? JSONSerialization.data(withJSONObject: dict), let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    var isCopyable: Bool {
        switch shareable {
        case is String, is [String]:
            return true
        case is UIImage, is [UIImage]:
            return true
        case is UIColor, is [UIColor]:
            return true
        case is URL, is [URL]:
            return true
        default:
            return false
        }
    }

    var isExpandable: Bool {
        switch self {
        case .multiple(title: _, contents: _):
            return true
        default:
            return false
        }
    }

    var id: Int {
        shareable.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shareable)
    }

    /// A style for a cell with the label that is right aligned
    case content(_ value: String, style: CopyCellStyleConfig)
    /// A style for a cell with a label on the left side of the cell with left-aligned and black text; on the right side is a label that has gray text and is right-aligned.
    case row(title: String, content: String, style: CopyCellStyleConfig = .gray)
    case toggleableRow(title: String, contents: [String], style: CopyCellStyleConfig = .gray)
    case multiple(title: String, contents: [Self])
    case custom(shareable: any Shareable, content: AnyView)

    var body: some View {
        CopyCellTypeView(type: self)
    }
}

@available(iOS 15.0, *)
struct CopyCellType_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                CopyCellType.row(title: "Hello", content: "World")
                CopyCellType.row(title: "Hello", content: "World", style: .chevron)
                CopyCellType.custom(shareable: "Boo!", content: AnyView(Text("👻")))
                CopyCellType.custom(shareable: UIImage(systemName: "gear"), content: AnyView(Image(systemName: "gear")))
            }

            VStack {
                CopyCellType.toggleableRow(title: "Title", contents: ["Content 1", "Content 2", "Content 3"])
                CopyCellType.toggleableRow(title: "Title", contents: ["Content 1", "Content 2", "Content 3"], style: .chevron)
            }

            VStack {
                CopyCellType.multiple(title: "Title", contents: [
                    CopyCellType.row(title: "Hello", content: "World"),
                    CopyCellType.row(title: "Title", content: "Content 2"),
                ])
                CopyCellType.multiple(title: "Title", contents: [
                    CopyCellType.row(title: "Hello", content: "World"),
                    CopyCellType.row(title: "Hello", content: "World"),
                    CopyCellType.toggleableRow(title: "Title", contents: ["Content 1", "Content 2", "Content 3"]),
                ])
                CopyCellType.multiple(title: "Title", contents: [
                    CopyCellType.row(title: "Hello", content: "World", style: .expandable),
                    CopyCellType.row(title: "Hello", content: "World", style: .expandable),
                    CopyCellType.toggleableRow(title: "Title", contents: ["Content 1", "Content 2", "Content 3"], style: .expandable),
                ])
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
