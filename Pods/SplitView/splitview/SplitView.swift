//
//  SplitStackView.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/20/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//
// swiftlint:disable all
import Foundation
import UIKit

/// Resizable Split View, inspired by [Apple’s Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)
open class SplitView: UIView {
    // MARK: - Properties
    // MARK: Private
    private let stack = UIStackView()
    /// Used for snapping
    private var smallestRatio: CGFloat = 0.02
    
    // MARK: Public
    /// The views being split
    public var views = [SplitSupportingView]()
    /// The handles between views
    public var handles = [SplitViewHandle]()
    
    /// The minimum width/height ratio for each view
    public var minimumRatio: CGFloat
    /// The animation duration when resizing views
    public var animationDuration: TimeInterval = 0.2
    
    /// Snap Behavior
    public var snap = [SplitViewSnapBehavior]() {
        didSet {
            self.update()
        }
    }
    
    /// This property determines the orientation of the arranged views.
    /// Assigning the `NSLayoutConstraint.Axis.vertical` value creates a column of views.
    /// Assigning the `NSLayoutConstraint.Axis.horizontal` value creates a row.
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.update()
        }
    }
    
    // MARK: - Initializers
    
    public init(with views: [UIView]? = nil, axis: NSLayoutConstraint.Axis = .vertical, minimumRatio: CGFloat = 0.0) {
        precondition(minimumRatio >= 0.0, "minimumRatio must be 0.0 or greater")
        precondition(minimumRatio < 1.0, "minimumRatio must be less than 1.0")
        
        self.minimumRatio = minimumRatio
        self.axis = axis
        
        super.init(frame: .zero)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = self.axis
        
        self.addSubview(stack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        
        if let newViews = views {
            for view in newViews {
                self.addView(view)
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Handling
    
    /// Add a view to your `SplitView`
    /// - warning:
    /// Currently the maximum supported views is 2
    open func addView(_ view: UIView, ratio: CGFloat = 0.5, minRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        precondition(ratio >= 0.0, "Ratio must be greater than zero")
        precondition(ratio <= 1.0, "Ratio must be less than one")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let organizer = SplitSupportingView(view: view, ratio: ratio, minRatio: minRatio, constraint: nil)
        views.append(organizer)
        
        if views.count % 2 == 0 {
            let handle = withHandle ?? SplitViewHandle()
            handle.axis = self.axis
            handle.translatesAutoresizingMaskIntoConstraints = false
            handles.append(handle)
            stack.addArrangedSubview(handle)
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
            handle.addGestureRecognizer(gesture)
        }
        
        stack.addArrangedSubview(organizer.view)
        
        self.assignRatios(newRatio: self.ratio(given: ratio, for: organizer), for: views.count - 1)
        self.setRatios()
    }
    
    private func update() {
        self.stack.axis = self.axis
        
        for handle in self.handles {
            handle.axis = self.axis
        }
        
        self.setRatios()
        
        UIView.animate(withDuration: self.animationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    private func setRatios() {
        let totalHandleSize: CGFloat = handles.reduce(0.0) { $0 + $1.size }
        let count = views.filter({ $0.ratio > 0 }).count
        
        let handleConstant = totalHandleSize/CGFloat(count)
        
        let original_constraints = views.compactMap({$0.constraint})
        
        for (i, view) in views.enumerated() {
            
            print("Setting", i, view.ratio, handleConstant)
            // using greaterThanOrEqual and lesser ratio to ignore rounding errors
            
            let constant = view.ratio > 0.0 ? -handleConstant: 0.0
            let ratio = max(view.ratio - 0.01, 0.0)
            
            if self.axis == .vertical {
                views[i].constraint = NSLayoutConstraint(item: views[i].view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .height, multiplier: ratio, constant: constant)
            } else {
                 views[i].constraint = NSLayoutConstraint(item: views[i].view, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .width, multiplier: ratio, constant: constant)
            }
        }
        
        let new_constraints = views.compactMap({$0.constraint})
        
        NSLayoutConstraint.deactivate(original_constraints)
        NSLayoutConstraint.activate(new_constraints)
    }
    
    private func ratio(given ratio: CGFloat, for organizer: SplitSupportingView)->CGFloat {
        if views.count == 1 {
            return 1.0
        }
        
        var minRatio: CGFloat = 0.0
        for view in views {
            if view == organizer {
                continue
            }
            minRatio += max(minimumRatio, view.minRatio)
        }
        if ratio >= 1.0 {
            return 1.0 - minRatio
        }
        
        let curMinRatio = max(minimumRatio, organizer.minRatio)
        
        if ratio <= self.smallestRatio {
            return curMinRatio
        }
        
        if ratio < curMinRatio {
            return curMinRatio
        }
        
        if ratio + minRatio >= 1.0 {
            return ratio - (ratio + minRatio - 1.0)
        }
        
        return ratio
    }
    
    private func assignRatios(newRatio: CGFloat, for index: Int) {
        var ratio = newRatio
        
        for snapBehavior in self.snap {
            for point in snapBehavior.snapPoints {
                if ratio > (point.percentage - point.tolerance) && ratio < (point.percentage + point.tolerance) {
                    ratio = point.percentage
                }
            }
        }
        
        var secondRatio = 1.0 - ratio
        
        if secondRatio < self.smallestRatio {
            secondRatio = 0.0
            ratio = 1.0
        }
        
        for (i, _) in views.enumerated() {
            if i == index {
                views[i].ratio = ratio
                continue
            }
            views[i].ratio = secondRatio
        }
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view as? SplitViewHandle else {
            return
        }
        
        guard let handleIndex = handles.firstIndex(of: handle) else {
            return
        }
        
        let organizer = views[handleIndex]
        
        switch sender.state {
        case .began:
            handle.initialOrigin = handle.frame.origin
            handle.isBeingUsed = true
            break
        case .changed:
            var newPoint = handle.initialOrigin!.y + sender.translation(in: handle).y
            var curPoint = handle.frame.origin.y
            if self.axis == .horizontal {
                newPoint = handle.initialOrigin!.x + sender.translation(in: handle).x
                curPoint = handle.frame.origin.x
            }
            
            var ratio: CGFloat = 0.0
            if curPoint != 0 {
                ratio = organizer.ratio * (newPoint/curPoint)
            } else {
                ratio = newPoint/stack.frame.width
                if self.axis == .horizontal {
                    ratio = newPoint/stack.frame.height
                }
            }
            views[handleIndex].ratio = self.ratio(given: max(ratio, views[handleIndex].minRatio), for: views[handleIndex])
            self.assignRatios(newRatio: views[handleIndex].ratio, for: handleIndex)
            
            self.setRatios()
            UIView.animate(withDuration: self.animationDuration) {
                self.layoutIfNeeded()
            }
            
            break
        case .ended:
            handle.isBeingUsed = false
        default:
            break
        }
    }
}
