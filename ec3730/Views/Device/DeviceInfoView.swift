import SwiftUI

struct DeviceInfoView: View {
    @StateObject var model = DeviceInfoModel()
    @StateObject var fingerprint = FingerPrintModel(
        URL(staticString: "https://fingerprint.netutils.workers.dev/"),
        onFinish: { model, webView in
            Task(priority: .background) {
                let htmlString = try await webView.evaluateJavaScript("document.documentElement.innerText.toString()")
                guard let htmlString = htmlString as? String else {
                    return
                }
                await model.update(fingerprint: htmlString)
            }
        }
    )
    @StateObject var fingerprintTwo = FingerPrintModel(
        URL(staticString: "https://fingerprint2.netutils.workers.dev/"),
        onFinish: { model, webView in
            Task(priority: .background) {
                let json = try await webView.evaluateJavaScript("document.documentElement.innerText.toString()")
                guard let json = json as? String, let jsonData = json.data(using: .utf8) else {
                    return
                }
                guard let d = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                    return
                }
                guard let htmlString = d["hash"] as? String else {
                    return
                }
                await model.update(fingerprint: htmlString)
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
                    Task {
                        date = .now
                        await model.reload()
                    }
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
        }
        .task {
            await model.attachFingerprint(model: fingerprint)
            await model.attachFingerprint(model: fingerprintTwo)
            await model.reload()
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
