import Foundation
import UIKit

open class SplitViewHandle: UIView {
    // MARK: - Properties
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
    
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.layoutConstraints()
        }
    }
    
    public var handleConstraints = [NSLayoutConstraint]()
    
    // MARK: - Initilizers
    init(with handle: UIView? = nil, axis: NSLayoutConstraint.Axis = .vertical, size: CGFloat = 18.0) {
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
    open func layoutConstraints() {
        self.removeConstraints(self.handleConstraints)
        handleConstraints.removeAll()
        
        if usingDefaultHandle {
            if self.axis == .vertical {
                handleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: 50.0)
                ]
            } else {
                handleConstraints = [
                    NSLayoutConstraint(item: self.handle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: 50.0),
                    NSLayoutConstraint(item: self.handle, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.5, constant: 0.0)
                ]
            }
        }
        
        if self.axis == .vertical {
            handleConstraints.append(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: self.size))
        } else {
            handleConstraints.append(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0.0, constant: self.size))
        }
        
        self.addConstraints(self.handleConstraints)
    }
}
