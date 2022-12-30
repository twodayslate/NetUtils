import SwiftUI

struct HostBarView: View {
    @State var text = ""
    var url: URL
    var date: Date
    @State var showInfo = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
            HStack(alignment: .center) {
                // it would be great if this could be a .bottomBar toolbar but it is too buggy
                TextField("", text: $text, prompt: Text(url.absoluteString))
                    .truncationMode(.middle)
                    .disabled(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)

                Button(action: {
                    showInfo.toggle()
                }, label: {
                    Image(systemName: "info.circle")
                })
            }
            .padding(.horizontal)
            .padding([.vertical], 6)

            HStack(alignment: .center) {
                Spacer()
                Text(date.ISO8601Format())
                    .font(.footnote)
                    .foregroundColor(Color(UIColor.separator))
                    .padding([.bottom], 6)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = date.ISO8601Format()
                        }, label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        })
                    }
                Spacer()
            }
        }
        .confirmationDialog("Information", isPresented: $showInfo) {
            Button(action: {
                UIPasteboard.general.string = url.absoluteString
            }, label: {
                Label("Copy URL", systemImage: "doc.on.doc")
            })
            Button(action: {
                UIPasteboard.general.string = date.ISO8601Format()
            }, label: {
                Label("Copy Date", systemImage: "doc.on.doc")
            })
        }.background(
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                .ignoresSafeArea()
        )
    }
}

#if DEBUG
    struct HostBarView_preview: PreviewProvider {
        static var previews: some View {
            Group {
                HostBarView(url: URL(staticString: "https://google.com"), date: Date.now)
            }
        }
    }
#endif
