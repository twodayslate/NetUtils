import SwiftUI

let handleVerticalPadding: CGFloat = 8
let handleThickness: CGFloat = 5
let spacerSize = 50.0

struct SnapDrawer<StateType: SnapState, Background: View, Content: View>: View {
    private let calculator: SnapPointCalculator<StateType>

    private var state: Binding<StateType>?

    private let background: (StateType.Visible) -> Background
    private let content: (StateType.Visible) -> Content

    @State
    private var currentResult: SnapPointCalculator<StateType>.SnapResult {
        didSet {
            state?.wrappedValue = currentResult.state
        }
    }

    @GestureState
    private var dragState = DragState.inactive

    private var minDrag: CGFloat
    private var maxDrag: CGFloat
    private let height: CGFloat

    init(snaps: [SnapPointCalculator<StateType>.Input],
         height: CGFloat,
         state: Binding<StateType>?,
         background: @escaping (StateType.Visible) -> Background,
         content: @escaping (StateType.Visible) -> Content) {
        self.height = height
        calculator = SnapPointCalculator(snaps: snaps, height: height)
        self.state = state
        self.background = background
        self.content = content
        _currentResult = State(initialValue: calculator(state: .largeState))
        minDrag = calculator.results.first?.offset ?? 0
        maxDrag = calculator.results.last?.offset ?? 0
    }

    public var body: some View {
        if let state = state, currentResult.state != state.wrappedValue {
            DispatchQueue.main.async {
                self.currentResult = self.calculator(state: state.wrappedValue)
            }
        }

        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)

        // let offset = min(maxDrag + 8, max(minDrag - 8, self.currentResult.offset + self.dragState.translation.height))

        let offset = min(maxDrag + 8, max(minDrag - 8, self.currentResult.offset + self.dragState.translation.height))
        // let offset = min(maxDrag + 8, self.dragState.translation.height) + spacerSize
        return ZStack {
            currentResult.state.visible.map { background($0).edgesIgnoringSafeArea(.all) }

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    currentResult.state.visible != nil ? Handle() : nil
                    currentResult.state.visible.map { content($0) }
                }
                .frame(height: currentResult.contentHeight)

                Spacer(minLength: 0)
            }

//            Text("min: \(minDrag) max: \(maxDrag) height: \(height) conOff: \(self.currentResult.offset) conHeight: \(currentResult.contentHeight) trans: \(self.dragState.translation.height) offset: \(offset)")
//                .foregroundColor(.red)
//                .background(.black)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.6), radius: 10.0)
        .offset(y: offset)
        .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0), value: dragState.translation.height)
        .gesture(drag)
    }

    private func onDragEnded(drag: DragGesture.Value) {
        currentResult = calculator(current: currentResult, drag: drag)
    }
}

struct Handle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: handleThickness / 2.0)
            .frame(width: 40, height: handleThickness)
            .foregroundColor(Color(UIColor.opaqueSeparator))
            .padding(.vertical, handleVerticalPadding)
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)

    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case let .dragging(translation):
            return translation
        }
    }

    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
