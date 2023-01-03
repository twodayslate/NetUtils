import SwiftUI

struct TappedText: View {
    @State private var selectedTextIndex: Int = 0

    var content: [String]

    var body: some View {
        Text(content[selectedTextIndex])
            .onTapGesture {
                let temp = selectedTextIndex + 1

                selectedTextIndex = temp >= content.count ? 0 : temp
            }
    }
}

#if DEBUG
    struct TappedTextPreview: PreviewProvider {
        static var previews: some View {
            TappedText(content: (1 ... 5).map { "Content \($0)" })
        }
    }
#endif
