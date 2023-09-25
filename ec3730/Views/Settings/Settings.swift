import MessageUI
import SimpleCommon
import SwiftUI

import StoreKit

enum AppTheme: Int {
    case system = 0
    case dark = 2
    case light = 1
}

enum BrowserSettings: Int {
    case inApp = 0
    case `default` = 1
}

struct Settings: View {
    @AppStorage("theme") var theme: AppTheme = .system
    @AppStorage("open_browser") var browser: BrowserSettings = .inApp
    @State var showEmailAlert = false
    @State var showMailSheet = false
    @State var showFirstRatingPrompt = false
    @State var showFailRatingPrompt = false

    @Environment(\.colorScheme) var colorScheme

    @Environment(\.simpleAppIcon) var appIcon

    var body: some View {
        List {
            Section {
                NavigationLink(destination: {
                    UIViewControllerView(DataFeedsTableViewController(style: .grouped))
                }, label: {
                    SimpleIconLabel(systemImage: "network", text: "Data Feeds")
                })
            }

            Section("Host") {
                NavigationLink(destination: {
                    HostModelWrapperView(view: HostSectionOrganizerView())
                }, label: {
                    SimpleIconLabel(systemImage: "text.line.first.and.arrowtriangle.forward", text: "Section Order")
                })
            }

            Section("Appearance") {
                NavigationLink(destination: AppIconChooser(), label: {
                    HStack {
                        SimpleIconLabel(image: appIcon?.image, text: "App Icon", iconScale: 1.0)
                    }
                })
                Picker(selection: $theme, content: {
                    Text("System")
                        .tag(AppTheme.system)
                    Text("Light")
                        .tag(AppTheme.light)
                    Text("Dark")
                        .tag(AppTheme.dark)
                }, label: {
                    SimpleIconLabel(systemImage: "paintbrush", text: "Theme")
                })
            }

            Section("Browser") {
                Picker(selection: $browser, content: {
                    Text("In-App Safari")
                        .tag(BrowserSettings.inApp)
                    Text("Default Browser")
                        .tag(BrowserSettings.default)
                }, label: {
                    SimpleIconLabel(systemImage: "safari", text: "Open Links in")
                })
            }

            Section {
                if MFMailComposeViewController.canSendMail() {
                    let subject = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String) + " v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
                    Button {
                        showMailSheet.toggle()
                    } label: {
                        contactRow
                    }
                    .sheet(isPresented: $showMailSheet, content: {
                        SimpleMailView(result: .constant(nil), subject: subject, toReceipt: ["zac+netutils@gorak.us"])
                    })
                } else {
                    let subject = ((Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String) + " v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)).replacingOccurrences(of: " ", with: "%20")
                    if let url = URL(string: "mailto:zac+netutils@gorak.us&subject=\(subject)"), UIApplication.shared.canOpenURL(url) {
                        Link(destination: url, label: {
                            contactRow
                        })
                    } else {
                        Button {
                            showEmailAlert.toggle()
                        } label: {
                            contactRow
                        }
                        .alert("Contact Us", isPresented: $showEmailAlert, actions: {}, message: {
                            Text("zac+netutils@gorak.us")
                        })
                    }
                }

                if let url = URL(string: "twitter://user?screen_name=twodayslate"), UIApplication.shared.canOpenURL(url) {
                    Link(destination: url, label: {
                        twitterRow
                    })
                } else if let url = URL(string: "https://twitter.com/twodayslate") {
                    Link(destination: url, label: {
                        twitterRow
                    })
                }
                Button {
                    let rand = arc4random_uniform(100)

                    if rand < 25 { // 25% can rate directly
                        rate()
                    } else {
                        showFirstRatingPrompt.toggle()
                    }
                } label: {
                    SimpleIconLabel(iconColor: .yellow, systemImage: "star.fill", text: "Rate")
                }
            }

            Section("Legal") {
                Link(destination: URL(string: "https://zac.gorak.us/ios/privacy")!, label: {
                    SimpleIconLabel(iconBackgroundColor: .gray, systemImage: "doc.text.magnifyingglass", text: "Privacy Policy")
                })
                Link(destination: URL(string: "https://zac.gorak.us/ios/terms")!, label: {
                    SimpleIconLabel(iconBackgroundColor: .gray, systemImage: "doc.text", text: "Terms of Use")
                })
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Rate", isPresented: $showFirstRatingPrompt, actions: {
            Button(role: .cancel) {
                rate()
            } label: {
                Text("Yes")
            }

            Button(role: .destructive) {
                showFailRatingPrompt.toggle()
            } label: {
                Text("No")
            }
        }, message: {
            Text("Do you love this app?")
        })
        .alert("Thank you!", isPresented: $showFailRatingPrompt, actions: {}, message: {
            Text("Thanks for the feedback! Please contact us with your specific feedback!")
        })
    }

    func rate() {
        UIApplication.shared.open(URL(string: "https://itunes.apple.com/gb/app/id1434360325?action=write-review&mt=8")!, options: [:], completionHandler: { _ in

        })
    }

    var contactRow: some View {
        SimpleIconLabel(iconBackgroundColor: colorScheme == .dark ? .white : .gray.opacity(0.3), iconColor: .red, systemImage: "at", text: "Contact")
    }

    @ViewBuilder
    var twitterRow: some View {
        SimpleIconLabel(iconBackgroundColor: .black, text: "X (formerly Twitter)", iconScale: 1.0) {
            Text("𝕏")
                .minimumScaleFactor(0.1)
        }
    }
}

#if DEBUG
    struct SettingsPreview: PreviewProvider {
        static var previews: some View {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    Settings()
                }
            }
        }
    }
#endif
