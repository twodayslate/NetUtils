import Foundation
import UIKit

/// The seperator/handle that is between each view in a `SplitView`
open class SplitViewHandle: UIView {
    // MARK: - Properties
    
    // MARK: Public
    /// The center view used for grabbing
    public var grabber: UIView
    /// The width/height of the view
    public var size: CGFloat
    /// Used for position tracking
    public var initialOrigin: CGPoint? = nil
    /// - returns:
    /// If being dragged returns `true`, `false` otherwise
    public var isBeingUsed = false
    
    /// This property determines the orientation of the arranged views.
    /// Assigning the `NSLayoutConstraint.Axis.vertical` value creates a column of views.
    /// Assigning the `NSLayoutConstraint.Axis.horizontal` value creates a row.
    public var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            self.layoutConstraints()
        }
    }
    
    /// The current constraints on the handle
    /// This is used when changing axises and should only be modified
    /// when overriding
    public var handleConstraints = [NSLayoutConstraint]()
    
    // MARK: - Initilizers
    init(with view: UIView, size: CGFloat) {
        self.size = size
        self.grabber = view

        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.grabber)
        
        self.grabber.translatesAutoresizingMaskIntoConstraints = false
        self.grabber.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.grabber.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.layoutConstraints()
    }

    /// Not implemented
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Handling
    
    /// Override this if you are cusomizing your seperator/handle
    /// Use `handleConstraints` as necessary
    open func layoutConstraints() {
        var tmpHandleConstraints = [NSLayoutConstraint]()

        // If they forgot to set a custom layout we will do the basics for them
        if self.axis == .vertical {
            tmpHandleConstraints.append(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: self.size))
        } else {
            tmpHandleConstraints.append(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: self.size))
        }
        
        NSLayoutConstraint.deactivate(self.handleConstraints)
        NSLayoutConstraint.activate(tmpHandleConstraints)
        self.handleConstraints = tmpHandleConstraints
    }
}

internal class DefaultSplitViewHandle: SplitViewHandle {
    override func layoutConstraints() {
        let defaultSize: CGFloat = 48.0
        var tmpHandleConstraints = [NSLayoutConstraint]()
        
        if self.axis == .vertical {
            tmpHandleConstraints = [
                NSLayoutConstraint(item: self.grabber, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
                NSLayoutConstraint(item: self.grabber, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: defaultSize),
                NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: self.size)
            ]
        } else {
            tmpHandleConstraints = [
                NSLayoutConstraint(item: self.grabber, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: defaultSize),
                NSLayoutConstraint(item: self.grabber, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0.0),
                NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: self.size)
            ]
        }

        NSLayoutConstraint.deactivate(self.handleConstraints)
        NSLayoutConstraint.activate(tmpHandleConstraints)
        self.handleConstraints = tmpHandleConstraints
    }
    
    override var isBeingUsed: Bool {
        didSet {
            if self.isBeingUsed {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.5) {
                        self.grabber.backgroundColor = self.grabber.backgroundColor?.withAlphaComponent(0.85)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        self.grabber.backgroundColor = self.grabber.backgroundColor?.withAlphaComponent(0.6)
                    }
                }
            }
        }
    }
}

// MARK: - Default
extension SplitViewHandle {
    /// The default handle.
    public class func useDefault() -> SplitViewHandle {
        let innerHandle = UIView()
        innerHandle.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        innerHandle.layer.cornerRadius = 4.0
        
        let handle = DefaultSplitViewHandle(with: innerHandle, size: 11.0)
        handle.backgroundColor = .black
        
        return handle
    }
}
