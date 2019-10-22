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


extension CGFloat
{
    /// https://stackoverflow.com/questions/35946499/how-to-truncate-decimals-to-x-places-in-swift
    func truncate(places : Int)-> CGFloat
    {
        return CGFloat(floor(pow(10.0, CGFloat(places)) * self)/pow(10.0, CGFloat(places)))
    }
}

/// Resizable Split View, inspired by [Apple’s Split View](https://support.apple.com/en-us/HT207582#split) for iPadOS and [SplitKit](https://github.com/macteo/SplitKit)
open class SplitView: UIView {
    // MARK: - Properties
    // MARK: Private and internal
    private let stack = UIStackView()

    /// The list of supporting views split by the split view
    internal var splitSupportingViews = [SplitSupportingView]()
    
    // MARK: Public

    /// The list of views split by the split view.
    public var splitSubviews: [UIView] {
        return self.splitSupportingViews.compactMap({ $0.view })
    }
    /// The handles between views
    public var handles = [SplitViewHandle]()
    
    /// The minimum width/height ratio for each view
    ///
    /// The default is 0.0
    public var minimumRatio: CGFloat {
        didSet {
            self.update()
        }
    }
    /// The animation duration when resizing views
    ///
    /// If you specify a negative value or 0, the changes are made without animating them.
    /// The default is 0.0 seconds
    public var animationDuration: TimeInterval = 0.0
    
    /// The precision of the movements. 1 is every 10%, 2 is every 1%, etc
    ///
    /// The default is 5
    public var precision = 5
    
    /// Snap Behavior
    public var snap = [SplitViewSnapBehavior]() {
        didSet {
            self.update()
        }
    }
    
    /// The axis along which the split views are laid out.
    ///
    /// This property determines the orientation of the split views.
    /// Assigning the `NSLayoutConstraint.Axis.vertical` value creates a column of views.
    /// Assigning the `NSLayoutConstraint.Axis.horizontal` value creates a row.
    /// The default value is `NSLayoutConstraint.Axis.horizontal`.
    public var axis: NSLayoutConstraint.Axis {
        didSet {
            self.update()
        }
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        self.minimumRatio = 0.0
        self.axis = .horizontal
        
        super.init(frame: frame)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fill
        stack.spacing = 0.0
        stack.alignment = .fill
        stack.axis = self.axis
        
        self.addSubview(stack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|", options: .alignAllCenterY, metrics: nil, views: ["stack": stack]))
    }
    
    public convenience init() {
        self.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Returns a new split view object that manages the provided views.
    /// - parameters:
    ///   - splitSubviews: The views to be split by the split view.
    public convenience init(splitSubviews: [UIView]) {
        self.init(frame: .zero)
        
        for view in splitSubviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSplitSubview(view)
        }
    }
    
    /// Not implemented
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Handling
    
    private func addHandle(_ handle: SplitViewHandle, at: Int) {
        handle.axis = self.axis
        handle.translatesAutoresizingMaskIntoConstraints = false
        handles.append(handle) // XXX: make sure this is in the right order
        stack.insertArrangedSubview(handle, at: at)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        handle.addGestureRecognizer(gesture)
    }
    
    /// Adds a view to the end of the splitSupportingViews array
    @available(swift, introduced: 1.3.0)
    open func addSplitSubview(_ view: UIView, desiredRatio: CGFloat = 0.5, minimumRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        self.insertSplitSubview(view, at: self.splitSupportingViews.count, desiredRatio: desiredRatio, minimumRatio: minimumRatio, withHandle: withHandle)
    }
    
    /// Adds the provided view to the array of split subviews at the specified index.
    open func insertSplitSubview(_ view: UIView, at: Int, desiredRatio: CGFloat = 0.5, minimumRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        precondition(desiredRatio >= 0.0, "Ratio must be greater than zero")
        precondition(desiredRatio <= 1.0, "Ratio must be less than one")
        
        var insertAtIndex = at
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let beforeSize = splitSupportingViews.count
        
        let organizer = SplitSupportingView(view: view, ratio: desiredRatio, minRatio: minimumRatio, constraint: nil)
        splitSupportingViews.insert(organizer, at: at)
        
        if beforeSize != 0 && at >= beforeSize {
            let handle = withHandle ?? SplitViewHandle.useDefault()
            insertAtIndex = self.stack.arrangedSubviews.count
            self.addHandle(handle, at: insertAtIndex)
            insertAtIndex += 1
        }
        
        stack.insertArrangedSubview(organizer.view, at: insertAtIndex)
        
        if beforeSize != 0 && at < beforeSize {
            let handle = withHandle ?? SplitViewHandle.useDefault()
            self.addHandle(handle, at: insertAtIndex + 1)
        }
        
        self.assignRatios(newRatio: self.ratio(given: desiredRatio, for: organizer), for: at)
        self.setRatios()
    }
    
    /// Removes the provided view from the stack’s array of split subviews.
    open func removeSplitSubview(_ view: UIView) {
        guard let index = self.splitSubviews.firstIndex(of: view) else {
            return
        }
        
        let organizer = splitSupportingViews.remove(at: index)
        
        stack.removeArrangedSubview(organizer.view)
        organizer.view.removeFromSuperview()
        
        if handles.count > 0 {
            let handle = self.handles.remove(at: max(index-1,0))
            stack.removeArrangedSubview(handle)
            handle.removeFromSuperview()
        }
        
        self.setRatios()
    }
    
    /// Add a view to your `SplitView`
    @available(swift, deprecated: 1.3.0, obsoleted: 2.0.0, renamed: "addSplitSubview")
    open func addView(_ view: UIView, ratio: CGFloat = 0.5, minRatio: CGFloat = 0.0, withHandle: SplitViewHandle? = nil) {
        self.addSplitSubview(view, desiredRatio: ratio, minimumRatio: minRatio, withHandle: withHandle)
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
        let minimumRatioToHoldHandle: CGFloat = 0.01
        let totalHandleSize: CGFloat = handles.reduce(0.0) { $0 + $1.size }
        let count = splitSupportingViews.filter({ $0.ratio > minimumRatioToHoldHandle }).count
        
        let handleConstant = totalHandleSize/CGFloat(count)
        
        let original_constraints = splitSupportingViews.compactMap({$0.constraint})
        
        for (i, view) in splitSupportingViews.enumerated() {
            // using greaterThanOrEqual and lesser ratio to ignore rounding errors
            // also subtracting 0.01 to fix rounding errors
            
            let constant = view.ratio > minimumRatioToHoldHandle ? -handleConstant: 0.0
            let ratio = max(view.ratio, 0.0)
                        
            if self.axis == .vertical {
                splitSupportingViews[i].constraint = NSLayoutConstraint(item: splitSupportingViews[i].view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .height, multiplier: ratio, constant: constant)
            } else {
                 splitSupportingViews[i].constraint = NSLayoutConstraint(item: splitSupportingViews[i].view, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .width, multiplier: ratio, constant: constant)
            }
        }
        
        let new_constraints = splitSupportingViews.compactMap({$0.constraint})
        
        NSLayoutConstraint.deactivate(original_constraints)
        NSLayoutConstraint.activate(new_constraints)
    }
    
    private func ratio(given ratio: CGFloat, for organizer: SplitSupportingView)->CGFloat {
        if splitSupportingViews.count == 1 {
            return 1.0
        }
        
        var minRatio: CGFloat = 0.0
        for view in splitSupportingViews {
            if view == organizer {
                continue
            }
            minRatio += max(minimumRatio, view.minRatio)
        }
        if ratio >= 1.0 {
            return 1.0 - minRatio
        }
        
        let curMinRatio = max(minimumRatio, organizer.minRatio)
        
        if ratio <= curMinRatio {
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
        
        var maxRatio: CGFloat = 1.0
        
        if splitSupportingViews.count == 1 {
            splitSupportingViews[0].ratio = maxRatio
            return
        }
        
        for snapBehavior in self.snap {
            for point in snapBehavior.snapPoints {
                if ratio > (point.percentage - point.tolerance) && ratio < (point.percentage + point.tolerance) {
                    ratio = point.percentage
                }
            }
        }

        var closestIndex = index == 0 ? 1 : 0
        
        if splitSupportingViews.count > 2 {
            // the handle controls this view and the view above
            closestIndex = index + 1
            if closestIndex >= splitSupportingViews.count {
                closestIndex = index - 1
            }
            
            // XXX: use reducers
            var ratioTotal: CGFloat = 0.0
            for (i, support) in splitSupportingViews.enumerated() {
                if i == index || i == closestIndex {
                    continue
                }
                ratioTotal += support.ratio
            }
            maxRatio = maxRatio - ratioTotal
        }
        
        var secondRatio = (maxRatio - ratio)
                
        let secondSmallestRatio = max(self.minimumRatio, splitSupportingViews[closestIndex].minRatio)
        if secondRatio < secondSmallestRatio {
            secondRatio = secondSmallestRatio
            ratio = maxRatio - secondRatio
        }
        
        ratio = ratio.truncate(places: self.precision)
        secondRatio = secondRatio.truncate(places: self.precision)
        
        splitSupportingViews[index].ratio = ratio
        splitSupportingViews[closestIndex].ratio = secondRatio
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view as? SplitViewHandle else {
            return
        }
        
        guard let handleIndex = handles.firstIndex(of: handle) else {
            return
        }
        
        let organizer = splitSupportingViews[handleIndex]
        
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
                if organizer.ratio <= 0 {
                    ratio = max(0.0, (newPoint/curPoint) - 1.0)
                } else {
                    ratio = organizer.ratio * (newPoint/curPoint)
                }
            } else {
                ratio = newPoint/stack.frame.height
                if self.axis == .horizontal {
                    ratio = newPoint/stack.frame.width
                }
                
                ratio = max(ratio, self.minimumRatio)
            }

            splitSupportingViews[handleIndex].ratio = self.ratio(given: max(ratio, splitSupportingViews[handleIndex].minRatio), for: splitSupportingViews[handleIndex])
            self.assignRatios(newRatio: splitSupportingViews[handleIndex].ratio, for: handleIndex)
            
            self.setRatios()
            UIView.animate(withDuration: self.animationDuration) {
                self.layoutIfNeeded()
            }
            
            break
        case .ended:
            handle.isBeingUsed = false
            handle.initialOrigin = nil
        default:
            break
        }
    }
}

// MARK: - Ratio
extension SplitView {
    /// The current ratio for all the split subviews
    public var ratios: [CGFloat] {
        return self.splitSupportingViews.compactMap({ $0.ratio })
    }
    
    /// The minimum ratios for all the split subviews
    public var minimumRatios: [CGFloat] {
        return self.splitSupportingViews.compactMap({ $0.minRatio })
    }
    
    /// Set the minimum ratio for a specific view
    public func setMinimumRatio(_ ratio: CGFloat, for view: UIView) {
        precondition(minimumRatio >= 0.0, "Ratio must be 0.0 or greater")
        precondition(minimumRatio < 1.0, "Ratio must be less than 1.0")
        
        guard let index = self.splitSubviews.firstIndex(of: view) else {
            return
        }
        
        self.splitSupportingViews[index].minRatio = ratio
    }
}

// MARK: - Stack

extension SplitView {
    /// A Boolean value that determines whether the split view lays out its split views relative to
    /// its layout margins.
    ///
    /// If `true`, the stack view will layout its split views relative to its layout margins.
    /// If `false`, it lays out the split views relative to its bounds. The default is `false`.
    public var isLayoutMarginsRelativeArrangement: Bool {
        set {
            stack.isLayoutMarginsRelativeArrangement = newValue
        }
        get {
            return stack.isLayoutMarginsRelativeArrangement
        }
    }
}
