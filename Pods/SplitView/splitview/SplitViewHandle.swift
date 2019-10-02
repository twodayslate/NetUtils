import Foundation
import UIKit

/// The seperator/handle that is between each view in a `SplitView`
open class SplitViewHandle: UIView {
    // MARK: - Properties
    // MARK: Class
    /// The default width/height size of the entire bar
    public static var defaultSize: CGFloat = 11.0
    /// The default width/height of the inner handle
    public static var defaultHandleSize: CGFloat = 48.0

    // MARK: Private
    private var usingDefaultHandle: Bool = false
    
    // MARK: Public
    /// The center view used for grabbing
    public var handle: UIView
    /// The width/height of the view
    public var size: CGFloat
    /// Used for position tracking
    public var initialOrigin: CGPoint? = nil
    /// - returns:
    /// If being dragged returns true, false otherwise
    public var isBeingUsed = false {
        didSet {
            if usingDefaultHandle {
                if self.isBeingUsed {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5) {
                            self.handle.backgroundColor = self.handle.backgroundColor?.withAlphaComponent(0.85)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2) {
                            self.handle.backgroundColor = self.handle.backgroundColor?.withAlphaComponent(0.6)
                        }
                    }
                }
            }
        }
    }
    
    /// This property determines the orientation of the arranged views.
    /// Assigning the `NSLayoutConstraint.Axis.vertical` value creates a column of views.
    /// Assigning the `NSLayoutConstraint.Axis.horizontal` value creates a row.
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.layoutConstraints()
        }
    }
    
    /// The current constraints on the handle
    /// This is used when changing axises and should only be modified
    /// when overriding
    private var handleConstraints = [NSLayoutConstraint]()
    
    // MARK: - Initilizers
    init(with handle: UIView? = nil, axis: NSLayoutConstraint.Axis = .vertical, size: CGFloat = SplitViewHandle.defaultSize) {
        self.axis = axis
        self.size = size
        if let newView = handle {
            self.handle = newView
        } else {
            self.handle = UIView()
            self.handle.translatesAutoresizingMaskIntoConstraints = false
            self.handle.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            self.handle.layer.cornerRadius = 4.0
            usingDefaultHandle = true
        }

        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        
        self.addSubview(self.handle)
        
        self.handle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.handle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.layoutConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Handling
    
    /// Override this if you are cusomizing your seperator/handle
    /// Use `handleConstraints` as necessary
    open func layoutConstraints() {
        var tmpHandleConstraints = [NSLayoutConstraint]()
        
        if usingDefaultHandle {
            if self.axis == .vertical {
                tmpHandleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: SplitViewHandle.defaultHandleSize)
                ]
            } else {
                tmpHandleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: SplitViewHandle.defaultHandleSize),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0.0)
                ]
            }
        }
        
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
