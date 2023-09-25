import SimpleCommon
import SwiftUI

struct AppIconChooser: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State var showAlert = false

    @Environment(\.simpleAppIconModel) var model

    var body: some View {
        List {
            Section {
                Button(action: {
                    Task {
                        do {
                            try await model.set(.dark)
                        } catch {
                            showAlert = true
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    AppIconView(icon: .dark, name: "Dark", subtitle: "@akhmadmaulidi")
                })

                Button(action: {
                    Task {
                        do {
                            try await model.set(.light)
                        } catch {
                            showAlert = true
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    AppIconView(icon: .light, name: "Light", subtitle: "@akhmadmaulidi")
                })
            }
            Section {
                Button(action: {
                    Task {
                        do {
                            try await model.set(.legacy)
                        } catch {
                            showAlert = true
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    AppIconView(icon: .legacy, name: "Legacy", subtitle: nil)
                })
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("App Icon")
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error"), message: Text("Unable to set icon. Try again later."), dismissButton: .default(Text("Okay")))
        })
    }
}

struct AppIcon: Codable {
    var alternateIconName: String?
    var name: String
    var assetName: String
    var subtitle: String?
}

struct AppIconView: View {
    var icon: SimpleAppIcon
    var name: String
    var subtitle: String?

    @Environment(\.simpleAppIcon) var appIcon

    var body: some View {
        HStack {
            icon.thumbnail()
            VStack(alignment: .leading) {
                Text("\(name)").foregroundColor(Color(UIColor.label))
                if let subtitle = subtitle {
                    Text("\(subtitle)").foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            if appIcon == icon {
                Spacer()
                Text("\(Image(systemName: "checkmark"))").bold().foregroundColor(.accentColor)
            }
        }
    }
}
