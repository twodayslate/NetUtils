import SwiftUI

struct CopyCellContentView: View {
    var content: String
    let style: CopyCellStyleConfig

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(content).foregroundColor(style.detailStyle.color)
            if style.chevron {
                CopyCellChevronView()
            }
        }
        .modifier(PaddingListModifier(padding: style.padding))
    }
}
