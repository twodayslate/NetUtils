import SwiftUI

struct CopyCellMultipleTypesView: View {
    var title: String
    var contents: [CopyCellType]

    @Binding var expanded: Bool

    var body: some View {
        DisclosureGroup(isExpanded: $expanded, content: {
            ForEach(contents) { content in
                content
            }
        }, label: {
            Text(title)
        })
        .padding()
    }
}
