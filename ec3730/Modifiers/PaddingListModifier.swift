import SwiftUI

struct PaddingListModifier: ViewModifier {
    let padding: [(Edge.Set, CGFloat?)]
    func body(content: Content) -> some View {
        if let first = padding.first {
            content
                .padding(first.0, first.1)
                .modifier(PaddingListModifier(padding: Array(padding.dropFirst())))
        } else {
            content
        }
    }
}
