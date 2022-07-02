import NavigationSplitTab
import SwiftUI

struct ContentView: View {
    @StateObject var model: NavigationSplitTabModel<ScreenId>
    @AppStorage("theme") var theme: Int = 0

    @StateObject var reachability = ReachabilityModel()

    init() {
        var root = ScreenId.host
        do {
            if let data = UserDefaults.standard.object(forKey: "lastScreen") as? Data {
                root = try JSONDecoder().decode(ScreenId.self, from: data)
            }
        } catch {
            print("Failed to decode")
        }
        _model = StateObject(wrappedValue:
            NavigationSplitTabModel(
                root: root,
                screens: [
                    .host,
                    .connectivity,
                    .ping,
                    .device,
                    .viewSource,
                    .settings,
                ]
            )
        )
    }

    var body: some View {
        model.navigation()
            .environmentObject(HostViewModel.shared)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .onChange(of: model.selectedScreen) { value in
                do {
                    let data = try JSONEncoder().encode(value)
                    UserDefaults.standard.set(data, forKey: "lastScreen")
                } catch {
                    print("Failed to encode", value)
                }
            }
            .onChange(of: theme) { value in
                // https://stackoverflow.com/a/68989580
                UIApplication.shared.connectedScenes
                    // Keep only active scenes, onscreen and visible to the user
                    .filter { $0.activationState == .foregroundActive }
                    // Keep only the first `UIWindowScene`
                    .first(where: { $0 is UIWindowScene })
                    // Get its associated windows
                    .flatMap { $0 as? UIWindowScene }?.windows.forEach { window in

                        switch value {
                        case 1:
                            window.rootViewController?.overrideUserInterfaceStyle = .light
                        case 2:
                            window.rootViewController?.overrideUserInterfaceStyle = .dark
                        default:
                            window.rootViewController?.overrideUserInterfaceStyle = .unspecified
                        }
                    }
            }
            .onChange(of: reachability.connection) { _ in
                // Update the modal so we get new icons for connectivity
                model.objectWillChange.send()
            }
    }
}

#if DEBUG
    struct ContentViewPreview: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
#endif
