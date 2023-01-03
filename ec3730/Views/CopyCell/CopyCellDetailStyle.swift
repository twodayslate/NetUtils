import SwiftUI

enum CopyCellDetailStyle {
    case gray
    case accent
    case label

    var color: Color {
        switch self {
        case .gray:
            return .gray
        case .accent:
            return .accentColor
        case .label:
            return Color(UIColor.label)
        }
    }
}
