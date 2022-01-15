import SwiftUI

@available(iOS 15.0.0, *)
struct PurchaseCellView: View {
    @ObservedObject var model: StoreKitModel
    @State var isRestoring: Bool = false
    
    var heading: String
    var subheading: String
    
    @State var imageSize: CGFloat = 64.0
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: .center) {
                //GeometryReader { geometry  in
                Image(systemName: "lock.shield.fill").renderingMode(.template).resizable().foregroundColor(.accentColor).aspectRatio(contentMode: .fit).frame(width: imageSize)
                //}.frame(width: imageSize)
                VStack(alignment: .leading) {
                    Text(self.heading).font(.headline)
                    Text(self.subheading).font(.subheadline)
                }
            }
            
            (Text("Start your free 3-day trial").bold() + Text(" then all \( "things" ) Data is available for \(self.model.defaultProduct?.displayPrice ?? "-")/month automatically")).font(.footnote)
            HStack {
                if self.isRestoring {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(action: {
                        Task {
                            await self.restore()
                        }
                    }, label: {
                        Text("Restore")
                    })
                }
                Button(action: {
                    Task {
                        await self.buy()
                    }
                }, label: {
                    Text("Subscibe Now for only $0.99").bold()
                }).padding().frame(maxWidth: .infinity).background(Color.accentColor).foregroundColor(.white).cornerRadius(16.0)
            }.padding(.vertical, 4)
            Text("Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.").font(.caption2).foregroundColor(Color(UIColor.systemGray2))
            HStack {
                Spacer()
                Link(destination: URL(string: "https://zac.gorak.us/ios/privacy")!, label: {
                    Text("Privacy Policy").underline().foregroundColor(Color(UIColor.systemGray))
                })
                Text("&")
                Link(destination: URL(string: "https://zac.gorak.us/ios/terms")!, label: {
                    Text("Terms of Use").underline().foregroundColor(Color(UIColor.systemGray))
                })
                Spacer()
            }.font(.caption2).foregroundColor(Color(UIColor.systemGray2))
        }
        .padding().background(Color(UIColor.systemBackground)).contextMenu(menuItems: {
            Button(action: {
                Task {
                    await self.restore()
                }
            }, label: {
                Label("Restore", systemImage: "arrow.clockwise")
            })
        })
    }


    func restore() async {
        self.isRestoring = true
        try? await self.model.restore()
        self.isRestoring = false
    }
    
    func buy() async {
        // TODO: generalize block
        guard let product = self.model.defaultProduct else {
            return
        }
        self.isRestoring = true
        let _ = try? await self.model.purchase(product)
        self.isRestoring = false
    }
}
    
@available(iOS 15.0, *)
struct LockedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PurchaseCellView(model: StoreKitModel.whois, heading: "Whois", subheading: "Subheading")
        }
    }
}
