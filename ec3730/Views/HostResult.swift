import Foundation
import SwiftUI
import Combine

struct HostResult: View {
    @State var shouldShare: Bool = false
    //@ObservedObject var model: HostViewModel
    
    @ObservedObject var group: HostDataGroup

    init(_ group: HostDataGroup){
        self.group = group
    }
    
    @State var text = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(self.group.results), id: \.self) { result in
                        if let data = HostSectionModel.configure(with: result) {
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
            VStack(alignment: .leading, spacing: 0.0) {
                Divider()
                HStack(alignment: .center) {
                    // it would be great if this could be a .bottomBar toolbar but it is too buggy
                    TextField("", text: $text, prompt: Text(group.url.absoluteString))
                    .disabled(true).textFieldStyle(RoundedBorderTextFieldStyle()).keyboardType(.URL)
                }.padding(.horizontal).padding([.vertical], 6)
                HStack(alignment: .center) {
                    Spacer()
                    Text(group.date.ISO8601Format()).font(.footnote).foregroundColor(Color(UIColor.separator)).padding([.bottom], 6)
                    Spacer()
                }
            }.background(VisualEffectView(effect: UIBlurEffect(style: .systemMaterial)).ignoresSafeArea(.all, edges: .horizontal)).ignoresSafeArea()
        }.navigationTitle(self.group.url.host ?? "Unknown Host")
    }
}
