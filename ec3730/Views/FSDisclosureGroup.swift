import SwiftUI

struct FSDisclosureGroup<Label, Content>: View where Label: View, Content: View {
  @Binding var isExpanded: Bool
  var content: () -> Content
  var label: () -> Label

  var body: some View {
    VStack(alignment: .leading, spacing: 0.0) {
        Button(action: {
            withAnimation {
                self.isExpanded.toggle()
            }
        }, label: {
            HStack(alignment: .center) {
                label()
                Image(systemName: "chevron.down").rotationEffect(self.isExpanded ? .degrees(0.0) : .degrees(-90.0)).padding()
            }
        })
        
        if self.isExpanded {
            content()
        }
    }
  }
}
