import SwiftUI
import WebKit

struct WebWrapperView: UIViewRepresentable {
    @Binding var webView: WKWebView
    @Binding var source: String
    @Binding var url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let view = webView
        view.navigationDelegate = context.coordinator
        return view
    }

    func updateUIView(_: WKWebView, context _: Context) {
        // no-op
    }

    func makeCoordinator() -> Coordintor {
        Coordintor(self)
    }

    class Coordintor: NSObject, WKNavigationDelegate {
        var wrapper: WebWrapperView
        var webView: WKWebView?

        init(_ wrapper: WebWrapperView) {
            self.wrapper = wrapper
            super.init()
        }

        private func setJavascript(completion block: (() -> Void)? = nil) {
            webView?.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { [self] source, error in

                guard error == nil else {
                    block?()
                    return
                }

                guard let source = source as? String else {
                    block?()
                    return
                }
                Task { @MainActor in
                    self.wrapper.source = source
                    block?()
                }
            })
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            if let url = webView.url {
                wrapper.url = url
            }
            self.webView = webView
            setJavascript {
                self.wrapper.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            if let url = webView.url {
                wrapper.url = url
            }
            self.webView = webView
            setJavascript {
                self.wrapper.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            DispatchQueue.main.async {
                self.wrapper.source.removeAll()
            }
            self.webView = webView
            wrapper.isLoading = true
            wrapper.source = ""
        }
    }
}
