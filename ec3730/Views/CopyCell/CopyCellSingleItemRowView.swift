import SwiftUI

struct CopyCellSingleItemRowView: View {
    var title: String
    var content: String
    let style: CopyCellStyleConfig

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
            Spacer()
            Text(content).foregroundColor(style.detailStyle.color)
            if style.chevron {
                CopyCellChevronView()
            }
        }
        .modifier(PaddingListModifier(padding: style.padding))
    }
}
