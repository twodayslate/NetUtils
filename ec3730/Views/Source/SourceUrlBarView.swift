import SwiftUI

struct SourceUrlBarView: View {
    @Binding var text: String
    var refresh: () -> Void
    var go: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
            HStack(alignment: .center) {
                Button {
                    refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                // it would be great if this could be a .bottomBar toolbar but it is too buggy
                TextField("https://google.com", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .disableAutocorrection(true)

                Button {
                    go()
                } label: {
                    Text("Go")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                .ignoresSafeArea(.all, edges: .horizontal)
        )
        .ignoresSafeArea()
    }
}

#if DEBUG
    struct SourceUrlBarViewPreview: PreviewProvider {
        static var previews: some View {
            Group {
                SourceUrlBarView(text: .constant(""), refresh: {}, go: {})
            }
        }
    }
#endif
