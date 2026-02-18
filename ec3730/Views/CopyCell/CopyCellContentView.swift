import SwiftUI

struct CopyCellContentView: View {
    var content: String
    let style: CopyCellStyleConfig

    private var rowContent: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(content).foregroundColor(style.detailStyle.color)
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
