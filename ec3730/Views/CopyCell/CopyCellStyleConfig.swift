import SwiftUI

struct CopyCellStyleConfig {
    var detailStyle: CopyCellDetailStyle
    var padding: [(Edge.Set, CGFloat?)] = [(Edge.Set.all, nil)]
    var chevron: Bool = false

    static let gray: Self = .init(detailStyle: .gray)
    // A Style for a cell in an multiple cell
    static let expandable: Self = .init(
        detailStyle: .label,
        padding: [
            ([.leading, .trailing], nil),
            (.top, 4),
        ]
    )
    static let chevron: Self = .init(detailStyle: .gray, chevron: true)
}
