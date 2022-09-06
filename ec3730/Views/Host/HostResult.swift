import Combine
import Foundation
import SwiftUI

struct HostResult: View {
    @State var shouldShare: Bool = false
    // @ObservedObject var model: HostViewModel

    @ObservedObject var group: HostDataGroup

    init(_ group: HostDataGroup) {
        self.group = group
    }

    @State var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(self.group.results.sorted(by: { $0.date < $1.date })), id: \.self) { result in
                        if let data = HostSectionModel.configure(with: result, group: group) {
                            HostResultSection(data: data)
                        } else {
                            VStack {
                                Text("Error - please contact the developer")
                                Text("\(result)")
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            HostBarView(url: group.url, date: group.date)
        }.navigationTitle(self.group.url.host ?? "Unknown Host")
    }
}
