import Foundation
import UIKit

internal struct SplitSupportingView: Equatable {
    public let view: UIView
    /// The current width/height ratio of `view`
    var ratio: CGFloat = .zero
    /// The minimum width/height ratio for `view`
    var minRatio: CGFloat = .zero
    /// The active constraints for width/height
    var constraint: NSLayoutConstraint? = nil
}
