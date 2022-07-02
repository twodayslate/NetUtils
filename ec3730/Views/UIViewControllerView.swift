import SwiftUI

struct UIViewControllerView<Wrapper: UIViewController>: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    var controller: Wrapper

    init(_ controller: @escaping @autoclosure () -> Wrapper) {
        self.controller = controller()
    }

    func makeUIViewController(context: Context) -> Wrapper {
        DispatchQueue.main.async {
            updateTitle(controller)
        }
        context.coordinator.parentObserver = controller.observe(\.parent, changeHandler: { vc, _ in
            updateTitle(vc)
        })

        return controller
    }

    func updateUIViewController(_ vc: Wrapper, context _: Context) {
        updateTitle(vc)
    }

    private func updateTitle(_ vc: Wrapper) {
        vc.parent?.title = vc.title
        vc.parent?.navigationItem.title = vc.navigationItem.title
        vc.parent?.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems
    }

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }
}

/// - SeeAlso: https://betterprogramming.pub/how-to-use-uiviewrepresentable-with-swiftui-7295bfec312b
struct Anything<Wrapper: UIView>: UIViewRepresentable {
    typealias Updater = (Wrapper, Context) -> Void

    var makeView: () -> Wrapper
    var update: (Wrapper, Context) -> Void

    init(_ makeView: @escaping @autoclosure () -> Wrapper,
         updater update: @escaping (Wrapper) -> Void) {
        self.makeView = makeView
        self.update = { view, _ in update(view) }
    }

    func makeUIView(context _: Context) -> Wrapper {
        makeView()
    }

    func updateUIView(_ view: Wrapper, context: Context) {
        update(view, context)
    }
}
