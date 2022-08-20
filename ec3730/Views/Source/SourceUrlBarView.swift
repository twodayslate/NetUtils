import SwiftUI

struct SourceUrlBarView: View {
    @Binding var text: String
    var refresh: (() -> Void)?
    var go: () -> Void
    var defaultText = "https://google.com"
    var goText = "Go"
    @Binding var isQuerying: Bool
    var cancel: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .ignoresSafeArea()
            HStack(alignment: .center) {
                if let refresh = refresh {
                    Button {
                        refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }

                HStack {
                    // it would be great if this could be a .bottomBar toolbar but it is too buggy
                    TextField(defaultText, text: $text)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onSubmit {
                            go()
                        }

                    if !text.isEmpty {
                        Button(
                            action: { text = "" },
                            label: {
                                Image(systemName: "delete.left")
                                    .foregroundColor(Color(UIColor.opaqueSeparator))
                            }
                        )
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(uiColor: .opaqueSeparator), lineWidth: 1)
                )
                .background(Color(uiColor: .systemBackground).cornerRadius(6))

                if isQuerying {
                    Button {
                        cancel?()
                    } label: {
                        Text("Querying")
                    }
                } else {
                    Button {
                        go()
                    } label: {
                        Text(goText)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                .ignoresSafeArea()
        )
    }
}

#if DEBUG
    struct SourceUrlBarViewPreview: PreviewProvider {
        static var previews: some View {
            Group {
                SourceUrlBarView(text: .constant(""), refresh: {}, go: {}, isQuerying: .constant(false))
            }
        }
    }
#endif
