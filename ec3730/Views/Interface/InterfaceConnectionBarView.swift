import SwiftUI

struct InterfaceConnectionBarView: View {
    @ObservedObject var model: ReachabilityModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
            HStack(alignment: .center) {
                Group {
                    connectionText
                }
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Toggle(isOn: .constant(model.connectionAvailable), label: {
                    connectionText
                })
                .labelsHidden()
                .disabled(true)
            }.padding(.horizontal).padding([.vertical], 6)
        }.background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).ignoresSafeArea(.all, edges: .horizontal)).ignoresSafeArea()
    }

    @ViewBuilder var connectionText: some View {
        switch model.connection {
        case .cellular:
            Text("Connected via cellular")
        case .wifi:
            if let ssid = model.ssid {
                Text("Connected via WiFi on \(ssid)")
            } else {
                Text("Connected via WiFi")
            }
        case .unavailable:
            Text("Network is unavailable")
        }
    }
}
