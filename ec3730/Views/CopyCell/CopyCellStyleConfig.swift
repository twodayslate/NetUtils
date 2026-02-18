import SwiftUI

enum CopyCellPaddingStyle {
    case standard
    case horizontalWithTop(CGFloat)
}

struct CopyCellStyleConfig {
    var detailStyle: CopyCellDetailStyle
    var paddingStyle: CopyCellPaddingStyle = .standard
    var chevron: Bool = false

    static let gray: Self = .init(detailStyle: .gray)
    /// A Style for a cell in an multiple cell
    static let expandable: Self = .init(
        detailStyle: .label,
        paddingStyle: .horizontalWithTop(4)
    )
    static let chevron: Self = .init(detailStyle: .gray, chevron: true)
}
