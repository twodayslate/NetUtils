import NetUtils
import SwiftUI

struct InterfaceListView: View {
    @StateObject var model = ReachabilityModel()

    var body: some View {
        VStack(spacing: 0) {
            List {
                let enabled = model.interfaces.filter(\.isUp)
                if !enabled.isEmpty {
                    Section("Enabled (Up)") {
                        ForEach(enabled) { interface in
                            row(for: interface)
                        }
                    }
                }
                let disabled = model.interfaces.filter { !$0.isUp }
                if !disabled.isEmpty {
                    Section("Disabled (Down)") {
                        ForEach(disabled) { interface in
                            row(for: interface)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.top, 0.5)
            .layoutPriority(1.0)
            InterfaceConnectionBarView(model: model)
        }
        .onAppear {
            model.reload()
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interfaces")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    model.reload()
                }, label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                })
            }
        }
    }

    func row(for interface: Interface) -> some View {
        NavigationLink(destination: {
            InterfaceView(model: model, interface: interface)
        }, label: {
            CopyCellView(title: interface.name, content: interface.address, backgroundColor: .clear)
        })
    }
}
