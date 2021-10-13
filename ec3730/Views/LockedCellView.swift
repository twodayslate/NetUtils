import SwiftUI

@available(iOS 15.0.0, *)
struct PurchaseCellView: View {
    @ObservedObject var model: StoreKitModel
    
    var body: some View {
        if let defaultProduct = self.model.defaultProduct {
            Button(action: {
                Task {
                    try? await self.model.purchase(defaultProduct)
                }
            }, label: {
                Text("Buy")
            })
        } else {
            Text("No product yet")
        }
    }
}


@available(iOS 15.0, *)
struct LockedCellView: View {
    var feed: DataFeedPurchaseProtocol
    var heading: String
    var subheading: String
    @State var isRestoring: Bool = false
    @State var shouldShare: Bool = false
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack {
                    let imageSize = min(geometry.size.height, geometry.size.width)/4.5
                    Image(systemName: "lock.shield.fill").renderingMode(.template).resizable().foregroundColor(.accentColor).frame(width: imageSize, height: imageSize)
                    VStack(alignment: .leading) {
                        Text(self.heading).font(.headline)
                        Text(self.subheading).font(.subheadline)
                    }
                }
                (Text("Start your free 3-day trial").bold() + Text(" then all \( self.feed.name) Data is available for \(self.feed.defaultProduct?.localizedPrice ?? "-")/month automatically")).font(.footnote)
                HStack {
                    if self.isRestoring {
                        ProgressView().progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button(action: {
                            self.restore()
                        }, label: {
                            Text("Restore")
                        })
                    }
                    Button(action: {
                        self.buy()
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
                Button(action: { self.shouldShare.toggle() }, label: {
                    Label("Restore", systemImage: "arrow.clockwise")
                })
            })
        }
        
    }
    
    func restore() {
        self.isRestoring = true
        self.feed.restore(completion: { _ in
            self.isRestoring = false
        })
    }
    
    func buy() {
        // TODO: generalize block
        self.isRestoring = true

        if let sub = (self.feed as? DataFeedSubscription), let defaultSub = sub.subscriptions.first {
            defaultSub.buy { result in
                self.isRestoring = false
                // swiftlint:disable:next line_length
                //self.iapDelegate?.didUpdateInAppPurchase(self.dataFeed, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
            return
        }

        if let one = (self.feed as? DataFeedOneTimePurchase) {
            one.oneTime.purchase { result in
                self.isRestoring = false
                // swiftlint:disable:next line_length
                //self.iapDelegate?.didUpdateInAppPurchase(self.dataFeed, error: nil, purchaseResult: result, restoreResults: nil, verifySubscriptionResult: nil, verifyPurchaseResult: nil, retrieveResults: nil)
            }
        }
    }
}
    
@available(iOS 15.0, *)
struct LockedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LockedCellView(feed: Monapi.current, heading: "Unlock Email, IP & Domain Data", subheading: "Identify malicious users, localize IPs, reduce fraud and undesirable signups and so much more!")
        }
    }
}
