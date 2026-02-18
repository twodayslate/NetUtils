import SwiftUI

struct CopyCellToggleableItemRowView: View {
    var title: String
    var contents: [String]
    let style: CopyCellStyleConfig

    private var rowContent: some View {
        HStack(alignment: .center) {
            Text(title)
            Spacer()
            TappedText(content: contents)
                .foregroundColor(style.detailStyle.color)

            if style.chevron {
                CopyCellChevronView()
            }
        }
    }

    var body: some View {
        switch style.paddingStyle {
        case .standard:
            rowContent.padding()
        case let .horizontalWithTop(topPadding):
            rowContent
                .padding(.horizontal)
                .padding(.top, topPadding)
        }
    }
}
