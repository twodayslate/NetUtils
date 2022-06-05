import StoreKit
import SwiftUI

@available(iOS 15.0.0, *)
struct PurchaseCellView: View {
    @ObservedObject var model: StoreKitModel
    @ObservedObject var sectionModel: HostSectionModel

    @State var isRestoring: Bool = false
    @State var showDemoData: Bool = false

    var heading: String {
        sectionModel.dataFeed.name
    }

    var subheading: String {
        sectionModel.service.description
    }

    @State var imageSize: CGFloat = 64.0

    enum Style {
        static let termsOpacity: CGFloat = 0.8
    }

    var body: some View {
        let isOneTime = (self.model.defaultProduct?.type == .nonConsumable)

        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image(systemName: "lock.shield.fill")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.accentColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize)
                VStack(alignment: .leading) {
                    Text(self.heading)
                        .font(.headline)
                    Text(self.subheading)
                        .font(.subheadline)
                }
                .foregroundColor(Color(uiColor: UIColor.label))
            }

            Button(action: {
                showDemoData.toggle()
            }, label: {
                Text("See an example query result!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
            })
            .frame(maxWidth: .infinity)
            .padding(.bottom)

            if !isOneTime {
                // we don't know what kind of product this is so let's just assume it is a trial so Apple doesn't yell at us
                let promoUnitType = self.model.defaultProduct?.subscription?.introductoryOffer?.period.unit ?? Product.SubscriptionPeriod.Unit.day

                let unitType = self.model.defaultProduct?.subscription?.subscriptionPeriod.unit ?? .month

                (Text("Start your free \(self.model.defaultProduct?.subscription?.introductoryOffer?.period.value ?? 3)-\(promoUnitType.debugDescription.lowercased()) trial").bold() + Text(" then all \(self.heading) Data is available for \(self.model.defaultProduct?.displayPrice ?? "-")/\(unitType.debugDescription.lowercased()) automatically"))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                    .multilineTextAlignment(.leading)
            }

            VStack {
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
                    VStack {
                        Button(action: {
                            Task {
                                await self.buy()
                            }
                        }, label: {
                            if isOneTime {
                                Text("Buy Now for only \(self.model.defaultProduct?.displayPrice ?? "-")")
                            } else {
                                Text("Subscibe Now for only \(self.model.defaultProduct?.displayPrice ?? "-")").bold()
                            }
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                    }
                }
                .padding(.vertical, 4)
            }

            Group {
                if isOneTime {
                    Text("Payment will be charged to your Apple ID account at the confirmation of purchase.")
                } else {
                    Text("Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase.")
                }

                HStack {
                    Spacer()
                    Text("[Privacy Policy](https://zac.gorak.us/ios/privacy)")
                        .underline() +
                        Text(" & ") +
                        Text("[Terms of Use](https://zac.gorak.us/ios/terms)")
                        .underline()
                    Spacer()
                }
            }
            .font(.caption2)
            .foregroundColor(Color(UIColor.systemGray2).opacity(Style.termsOpacity))
            .tint(Color(UIColor.systemGray).opacity(Style.termsOpacity))
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .contextMenu(menuItems: {
            Button(action: {
                Task {
                    await self.restore()
                }
            }, label: {
                Label("Restore", systemImage: "arrow.clockwise")
            })
        })
        .sheet(isPresented: $showDemoData, content: {
            HostViewSectionFocusView(model: sectionModel.demoModel, url: sectionModel.demoUrl, date: sectionModel.demoDate)
        })
    }

    func restore() async {
        isRestoring = true
        try? await model.restore(completion: {
            self.isRestoring = false
        })
    }

    func buy() async {
        // TODO: generalize block
        guard let product = model.defaultProduct else {
            return
        }
        isRestoring = true
        _ = try? await model.purchase(product)
        isRestoring = false
    }
}

@available(iOS 15.0, *)
struct LockedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PurchaseCellView(model: StoreKitModel.whois, sectionModel: WhoisXmlDnsSectionModel())
        }

        Group {
            PurchaseCellView(model: StoreKitModel.whois, sectionModel: WhoisXmlDnsSectionModel())
        }.preferredColorScheme(.dark)
    }
}
