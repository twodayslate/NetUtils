import Foundation
import WebKit

@MainActor
class FingerPrintModel: ObservableObject {
    var url: URL
    var _onFinish: (FingerPrintModel, WKWebView) -> Void
    weak var parent: DeviceInfoModel?

    @Published var fingerprint: String?
    @Published var didFinish = false

    init(_ url: URL, onFinish: @escaping (FingerPrintModel, WKWebView) -> Void) {
        self.url = url
        _onFinish = onFinish
    }

    func reload(_ webview: WKWebView) {
        fingerprint = nil
        webview.load(URLRequest(url: url))
    }

    func onFinish(_ model: FingerPrintModel, _ webview: WKWebView) {
        didFinish = true
        _onFinish(model, webview)
    }

    func update(fingerprint: String) async {
        self.fingerprint = fingerprint
        await parent?.reloadFingerprints()
    }
}

extension FingerPrintModel: Equatable {
    static func == (lhs: FingerPrintModel, rhs: FingerPrintModel) -> Bool {
        lhs.url == rhs.url
    }
}
