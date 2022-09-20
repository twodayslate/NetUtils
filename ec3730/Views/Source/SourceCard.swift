import Runestone
import SwiftUI
import TreeSitterCSSRunestone
import TreeSitterHTMLRunestone
import TreeSitterJavaRunestone
import TreeSitterJavaScriptRunestone
import TreeSitterJSON5Runestone
import TreeSitterJSONRunestone
import TreeSitterMarkdownRunestone
import WebKit

import RunestoneTomorrowTheme

extension TreeSitterLanguage: Hashable {
    public static func == (lhs: TreeSitterLanguage, rhs: TreeSitterLanguage) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(languagePointer.debugDescription)
    }
}

struct SourceCardView: View {
    @State var source: String = ""
    @State var url = URL(staticString: "https://google.com")
    @State var isLoading = false
    @State var urlText = ""
    @State var textView = TextView()
    @State var webView = WKWebView()
    @State var language: TreeSitterLanguage = .javaScript
    @State var errorParsingUrl = false

    @State var showShareSheet = false

    let availableLanguages: [(String, TreeSitterLanguage)] = [
        ("HTML", .html),
        ("CSS", .css),
        ("Markdown", .markdown),
        ("JSON", .json),
        ("JSON5", .json5),
        ("JavaScript", .javaScript),
        ("Java", .java),
    ]

    enum Style {
        static let minimumSizeFration = 0.25
    }

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                GeometryReader { reader in
                    WebWrapperView(webView: $webView, source: $source, url: $url, isLoading: $isLoading)
                        .padding(.bottom, reader.size.height * Style.minimumSizeFration)
                }
                GeometryReader { reader in
                    VStack {
                        Spacer()
                        SnapDrawer(snaps: [
                            SnapPointCalculator.Input(state: NetUtilsSnapState.full, point: SnapPoint.fraction(1.0)),
                            SnapPointCalculator.Input(state: NetUtilsSnapState.large, point: SnapPoint.fraction(0.75)),
                            SnapPointCalculator.Input(state: NetUtilsSnapState.medium, point: SnapPoint.fraction(0.5)),
                            SnapPointCalculator.Input(state: NetUtilsSnapState.tiny, point: SnapPoint.fraction(0.25)),
                        ],
                        height: reader.size.height,
                        state: nil,
                        background: { _ in VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)) }) { state in
                            VStack(spacing: 0) {
                                if state != .tiny {
                                    VStack {
                                        ZStack {
                                            HStack {
                                                Spacer()
                                                Picker(selection: $language, content: {
                                                    ForEach(availableLanguages, id: \.self.0) { language in
                                                        Text(language.0)
                                                            .id(language.1)
                                                            .tag(language.1)
                                                    }
                                                }, label: {
                                                    Text("HTML")
                                                        .bold()
                                                })
                                                .pickerStyle(.menu)
                                                Spacer()
                                            }

                                            HStack {
                                                Spacer()
                                                Button {
                                                    showShareSheet.toggle()
                                                } label: {
                                                    Image(systemName: "square.and.arrow.up")
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        Divider()
                                    }
                                }
                                RunestoneView(text: $source, textView: $textView)
                            }
                        }
                    }
                    .id(reader.size.height)
                }
            }
            SourceUrlBarView(text: $urlText, refresh: {
                webView.reload()
            }, go: query, isQuerying: .constant(false))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("View Source")
        .padding(.top, 0.5)
        .background(Color(UIColor.systemGroupedBackground))
        .onChange(of: url) { _ in
            urlText = url.absoluteString
        }
        .onAppear {
            webView.load(URLRequest(url: url))
        }
        .onChange(of: source) { text in
            updateTextView(text: text, language: language)
        }
        .onChange(of: language) { lang in
            updateTextView(text: source, language: lang)
        }
        .sheet(isPresented: $showShareSheet, content: {
            ShareSheetView(activityItems: [source])
        })
        .alert("Unable to parse URL", isPresented: $errorParsingUrl) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(urlText)")
        }
    }

    private func query() {
        let text = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if var url = URL(string: text) {
            if url.scheme == nil {
                url = url.with(scheme: "https") ?? url
            }
            webView.evaluateJavaScript("document.body.remove()") { _, _ in
                webView.load(URLRequest(url: url))
            }
        } else {
            errorParsingUrl.toggle()
        }
    }

    private func updateTextView(text: String, language lang: TreeSitterLanguage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let state = TextViewState(text: text, theme: TomorrowTheme(), language: lang)
            DispatchQueue.main.async {
                textView.selectedRange = .init(location: 0, length: 0)
                textView.setState(state)
            }
        }
    }
}

#if DEBUG
    struct SourceCardViewPreview: PreviewProvider {
        static var previews: some View {
            Group {
                NavigationView {
                    SourceCardView()
                }
            }.preferredColorScheme(.light)
            Group {
                NavigationView {
                    SourceCardView()
                }
            }.preferredColorScheme(.dark)
        }
    }
#endif
