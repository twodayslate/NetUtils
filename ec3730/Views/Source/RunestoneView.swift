import Runestone
import SwiftUI

struct RunestoneView: UIViewRepresentable {
    @Binding var text: String
    @Binding var textView: TextView

    func makeUIView(context _: Context) -> TextView {
        let view = textView
        view.backgroundColor = .clear
        view.isEditable = false
        view.contentInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        return view
    }

    func updateUIView(_ uiView: TextView, context _: Context) {
        uiView.text = text
    }
}
