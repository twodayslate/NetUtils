import NetUtils
import SwiftUI

struct InterfaceListView: View {
    @StateObject var model = ReachabilityModel()

    @State var upEnabled = true
    @State var downEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    let enabled = model.interfaces.filter(\.isUp)
                    FSDisclosureGroup(isExpanded: $upEnabled, content: {
                        VStack(spacing: 0) {
                            ForEach(enabled) { interface in
                                row(for: interface)
                                    .listRowInsets(.none)
                            }
                        }
                        .cornerRadius(6)
                    }, label: {
                        HStack(alignment: .center) {
                            Text("Enabled (Up)").font(.headline).padding()
                            Spacer()
                        }
                    })

                    let disabled = model.interfaces.filter { !$0.isUp }
                    FSDisclosureGroup(isExpanded: $downEnabled, content: {
                        VStack(spacing: 0) {
                            ForEach(disabled) { interface in
                                row(for: interface)
                                    .listRowInsets(.none)
                            }
                        }
                        .cornerRadius(6)
                    }, label: {
                        HStack(alignment: .center) {
                            Text("Disabled (Down)").font(.headline).padding()
                            Spacer()
                        }
                    })
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .padding(.top, 0.15)
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
            CopyCellView(title: interface.name, content: interface.address, withChevron: true)
        })
    }
}
