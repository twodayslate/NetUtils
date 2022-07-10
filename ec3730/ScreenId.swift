import NavigationSplitTab
import Reachability
import SwiftUI

enum ScreenId: ScreenIdentifierProtocol, Codable {
    case host
    case connectivity
    case ping
    case viewSource
    case device
    case settings
    case showMore

    var body: some View {
        switch self {
        case .host:
            HostView()
        case .connectivity:
            InterfaceListView()
        case .ping:
            PingSwiftUIViewController()
        case .viewSource:
            SourceCardView()
        case .device:
            DeviceInfoView()
        case .settings:
            UIViewControllerView(SettingsTableViewController(style: .grouped))
        case .showMore:
            ShowMoreView()
        }
    }

    var id: Int {
        hashValue
    }

    var tabImage: Image {
        switch self {
        case .host:
            return Image("Network").renderingMode(.template)
        case .connectivity:
            let connection = Reachability.shared.connection
            if connection == .wifi || connection == .cellular {
                return Image("Connected").renderingMode(.template)
            } else {
                return Image("Disconnected").renderingMode(.template)
            }
        case .ping:
            return Image("Ping").renderingMode(.template)
        case .viewSource:
            return Image("Source").renderingMode(.template)
        case .device:
            return Image("Device").renderingMode(.template)
        case .settings:
            return Image("Settings").renderingMode(.template)
        case .showMore:
            return Image("More").renderingMode(.template)
        }
    }

    var selectedTabImage: Image {
        switch self {
        case .host:
            return Image("Network_selected").renderingMode(.template)
        case .connectivity:
            let connection = Reachability.shared.connection
            if connection == .wifi || connection == .cellular {
                return Image("Connected_selected").renderingMode(.template)
            } else {
                return Image("Disconnected_selected").renderingMode(.template)
            }
        case .ping:
            return Image("Ping_selected").renderingMode(.template)
        case .viewSource:
            return Image("Source_selected").renderingMode(.template)
        case .device:
            return Image("Device_selected").renderingMode(.template)
        case .settings:
            return Image("Settings_selected").renderingMode(.template)
        case .showMore:
            return Image("More_selected").renderingMode(.template)
        }
    }

    var isDisabled: Bool {
        false
    }

    var title: String {
        switch self {
        case .host:
            return "Host"
        case .connectivity:
            return "Connectivity"
        case .ping:
            return "Ping"
        case .viewSource:
            return "View Source"
        case .device:
            return "Device"
        case .settings:
            return "Settings"
        case .showMore:
            return "More"
        }
    }
}
