import SwiftUI

@available(iOS 15.0, *)
struct HostModelWrapperView<Content: View>: View {
    var view: Content
    
    var body: some View {
        view.environmentObject(HostViewModel.shared)
    }
}
