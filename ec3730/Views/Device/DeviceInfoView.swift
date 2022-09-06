import SwiftUI

struct DeviceInfoView: View {
    @StateObject var model = DeviceInfoModel()
    @StateObject var fingerprint = FingerPrintModel(
        URL(staticString: "https://fingerprint.netutils.workers.dev/"),
        onFinish: { model, webView in
            webView.evaluateJavaScript("document.documentElement.innerText.toString()") { text, _ in
                guard let htmlString = text as? String else {
                    return
                }

                Task { @MainActor in
                    model.update(fingerprint: htmlString)
                }
            }
        }
    )
    @StateObject var fingerprintTwo = FingerPrintModel(
        URL(staticString: "https://fingerprint2.netutils.workers.dev/"),
        onFinish: { model, webView in
            webView.evaluateJavaScript("document.documentElement.innerText.toString()") { json, _ in
                guard let json = json as? String, let jsonData = json.data(using: .utf8) else {
                    return
                }
                guard let d = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    return
                }
                if let htmlString = d["hash"] as? String {
                    model.update(fingerprint: htmlString)
                }
            }
        }
    )
    @State private var date = Date.now

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(model.sections) { section in
                    Group {
                        if section.enabled {
                            DeviceInfoSectionView(section: section)
                        }
                    }
                }
                Divider()
                Text("Last Updated \(date.ISO8601Format(.iso8601))")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(alignment: .center)
                    .padding()
            }
            .id(date)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .background {
            ZStack {
                WebkitOverlayView(model: fingerprint)
                    .allowsHitTesting(false)
                WebkitOverlayView(model: fingerprintTwo)
                    .allowsHitTesting(false)
            }
        }
        .navigationBarTitle("Device")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        date = .now
                        model.reload()
                    }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            Task {
                model.attachFingerprint(model: fingerprint)
                model.attachFingerprint(model: fingerprintTwo)
            }
        }
    }
}

#if DEBUG
    struct DeviceInfoViewPreview: PreviewProvider {
        static var previews: some View {
            DeviceInfoView()
        }
    }
#endif
