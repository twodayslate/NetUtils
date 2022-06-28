import SwiftUI
import WebKit

struct WebkitOverlayView: UIViewRepresentable {
    @ObservedObject var model: FingerPrintModel

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.frame = .init(x: 0, y: 0, width: 1, height: 1)
        webView.alpha = 0.0005
        webView.navigationDelegate = context.coordinator
        DispatchQueue.main.async {
            model.reload(webView)
        }
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        // no-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(model)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @ObservedObject var model: FingerPrintModel

        init(_ model: FingerPrintModel) {
            self.model = model
        }

        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            model.onFinish(model, webView)
        }
    }
}
