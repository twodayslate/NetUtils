import SwiftUI

@available(iOS 15.0, *)
/**
 This is a wrapper view to ensure that the gien view has the shared HostViewModel shared environment object
 */
struct HostModelWrapperView<Content: View>: View {
    var view: Content
    
    var body: some View {
        view.environmentObject(HostViewModel.shared)
    }
}
