import SwiftUI

struct InterfaceConnectionBarView: View {
    @ObservedObject var model: ReachabilityModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
            HStack(alignment: .center) {
                Toggle(isOn: .constant(model.connectionAvailable), label: {
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
                    case .none:
                        Text("No network available")
                    }
                })
                .disabled(true)
//                // it would be great if this could be a .bottomBar toolbar but it is too buggy
//                TextField(self.defaultUrl, text: $text, onCommit: { Task {
//                    await self.query { errors in
//                        guard errors.count <= 0 else {
//                            self.showErrors = true
//                            self.errors = errors
//                            return
//                        }
//                    }
//                }
//                })
//                .textInputAutocapitalization(.never)
//                .id(dismissKeyboard)
//                .disableAutocorrection(true)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .keyboardType(.URL)
//                .padding(.leading, geometry.safeAreaInsets.leading)
//                if self.model.isQuerying {
//                    Button("Cancel", action: {
//                        self.cancel()
//                    }).padding(.trailing, geometry.safeAreaInsets.trailing)
//                } else {
//                    Button("Lookup", action: {
//                        Task {
//                            await self.query { errors in
//                                guard errors.count <= 0 else {
//                                    self.showErrors = true
//                                    self.errors = errors
//                                    return
//                                }
//                            }
//                        }
//                    }).padding(.trailing, geometry.safeAreaInsets.trailing)
//                }
            }.padding(.horizontal).padding([.vertical], 6)
        }.background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).ignoresSafeArea(.all, edges: .horizontal)).ignoresSafeArea()
    }
}
