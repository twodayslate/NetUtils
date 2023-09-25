import NavigationSplitTab
import StoreKit
import SwiftUI

@available(iOS 15.0.0, *)
struct PurchaseCellView: View {
    @ObservedObject var model: StoreKitModel
    @ObservedObject var sectionModel: HostSectionModel

    @EnvironmentObject var demoSheet: DemoSheet
    @EnvironmentObject var navigation: NavigationSplitTabModel<ScreenId>

    @State var isRestoring: Bool = false
    @State var showDemoData: Bool = false
    @State var subscriptionPeriod = Int.random(in: 0 ..< 100) > 50 ? Product.SubscriptionPeriod.Unit.month : .year

    var heading: String {
        sectionModel.dataFeed.name
    }

    var subheading: String {
        sectionModel.service.description
    }

    @State var imageSize: CGFloat = 64.0

    enum Style {
        static let termsOpacity: CGFloat = 0.7
        static let buyButtonCornerRadius: CGFloat = 16.0
    }

    var isOneTimePurchase: Bool {
        model.defaultProduct?.type == .nonConsumable
    }

    @State var supportsIntroOffer = false

    var body: some View {
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
                demoSheet.model = sectionModel
            }, label: {
                Text("See an example query result!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColor)
            })
            .frame(maxWidth: .infinity)
            .padding(.bottom)

            if !isOneTimePurchase, supportsIntroOffer {
                let promoUnitType = product?.subscription?.introductoryOffer?.period.unit ?? Product.SubscriptionPeriod.Unit.day

                let unitType = product?.subscription?.subscriptionPeriod.unit ?? .month

                (Text("Start your free \(product?.subscription?.introductoryOffer?.period.value ?? 3)-\(promoUnitType.debugDescription.lowercased()) trial").bold() + Text(" then all \(self.heading) Data is available for \(product?.displayPrice ?? "-")/\(unitType.debugDescription.lowercased()) automatically"))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: UIColor.secondaryLabel))
                    .multilineTextAlignment(.leading)
            }

            VStack {
                HStack {
                    Button(action: {
                        Task {
                            await self.restore()
                        }
                    }, label: {
                        Text("Restore")
                    })
                    .disabled(isRestoring)

                    buyButton()
                }
                .padding(.vertical, 4)
                if !isOneTimePurchase {
                    Button {
                        navigation.selectedScreen = .settings
                    } label: {
                        Text("More Subscription Options in Settings")
                            .font(.caption)
                            .opacity(0.7)
                    }
                    .padding(.bottom, 4)
                }
            }

            purchaseTerms()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .contextMenu(menuItems: {
            Button {
                Task {
                    await buy()
                }
            } label: {
                Label(isOneTimePurchase ? "Buy" : "Subscribe", systemImage: "lock")
            }
            Button {
                Task {
                    await self.restore()
                }
            } label: {
                Label("Restore", systemImage: "arrow.clockwise")
            }
            if !isOneTimePurchase {
                Button {
                    if subscriptionPeriod == .month {
                        subscriptionPeriod = .year
                    } else {
                        subscriptionPeriod = .month
                    }
                } label: {
                    Label("Change subscription period", systemImage: "calendar")
                }
            }
            Divider()
            Button {
                demoSheet.model = sectionModel
            } label: {
                Label("Show example query", systemImage: "doc.text")
            }
        })
        .task(id: product) {
            withAnimation {
                supportsIntroOffer = false
            }
            let value = await product?.subscription?.isEligibleForIntroOffer ?? false
            withAnimation {
                supportsIntroOffer = value
            }
        }
    }

    var product: Product? {
        if isOneTimePurchase {
            return model.defaultProduct
        }

        return model.products?.filter {
            $0.subscription?.subscriptionPeriod.unit == subscriptionPeriod
        }.first ?? model.defaultProduct
    }

    private func buyButton() -> some View {
        Button(action: {
            Task {
                await self.buy()
            }
        }, label: {
            Group {
                if isOneTimePurchase {
                    Text("Buy Now for only \(product?.displayPrice ?? "-")").bold()
                } else {
                    Text("Subscibe Now for only \(product?.displayPrice ?? "-")").bold()
                }
            }
            .opacity(isRestoring ? 0.1 : 1.0)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(Style.buyButtonCornerRadius)
        })
        .disabled(isRestoring)
        .overlay {
            RoundedRectangle(cornerRadius: Style.buyButtonCornerRadius)
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .opacity(isRestoring ? 1.0 : 0.0)
        }
        .overlay {
            if isRestoring {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.accentColor)
            }
        }
    }

    private func purchaseTerms() -> some View {
        Group {
            if isOneTimePurchase {
                Text("Payment will be charged to your Apple ID account at the confirmation of purchase. ") + privacyAndTerms()
            } else {
                Text("Payment will be charged to your Apple ID account at the confirmation of purchase. The subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. ") + privacyAndTerms()
            }
        }
        .font(.caption2)
        .foregroundColor(Color(UIColor.tertiaryLabel))
        .tint(Color(UIColor.secondaryLabel).opacity(Style.termsOpacity))
    }

    private func privacyAndTerms() -> Text {
        Text("By using our services you agree to and have read our ") +
            Text("[Privacy Policy](https://zac.gorak.us/ios/privacy)")
            .underline() +
            Text(" and ") +
            Text("[Terms of Use](https://zac.gorak.us/ios/terms)")
            .underline() +
            Text(".")
    }

    func restore() async {
        isRestoring = true
        do {
            try await model.restore()
        } catch {}
        isRestoring = false
    }

    func buy() async {
        // TODO: generalize block
        guard let product else {
            return
        }
        isRestoring = true
        do {
            _ = try await model.purchase(product)
        } catch {}
        isRestoring = false
    }
}

@available(iOS 15.0, *)
struct LockedCellView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Group {
                PurchaseCellView(model: StoreKitModel.whois, sectionModel: WhoisXmlDnsSectionModel())
            }

            Group {
                PurchaseCellView(model: StoreKitModel.whois, sectionModel: WhoisXmlDnsSectionModel())
            }.preferredColorScheme(.dark)
        }.environmentObject(NavigationSplitTabModel(root: ScreenId.host, screens: [.host, .settings]))
    }
}
