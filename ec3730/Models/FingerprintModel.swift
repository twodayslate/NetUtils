import Foundation
import WebKit

class FingerPrintModel: ObservableObject {
    var url: URL
    var _onFinish: (FingerPrintModel, WKWebView) -> Void
    weak var parent: DeviceInfoModel?

    @Published var fingerprint: String?

    init(_ url: URL, onFinish: @escaping (FingerPrintModel, WKWebView) -> Void) {
        self.url = url
        _onFinish = onFinish
    }

    func reload(_ webview: WKWebView) {
        fingerprint = nil
        webview.load(URLRequest(url: url))
    }

    func onFinish(_ model: FingerPrintModel, _ webview: WKWebView) {
        _onFinish(model, webview)
    }

    func update(fingerprint: String) {
        Task { @MainActor in
            self.fingerprint = fingerprint
            self.parent?.reloadFingerprints()
        }
    }
}

extension FingerPrintModel: Equatable {
    static func == (lhs: FingerPrintModel, rhs: FingerPrintModel) -> Bool {
        lhs.url == rhs.url
    }
}
