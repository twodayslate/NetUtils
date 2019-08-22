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

class SplitStackViewHandle: UIView {
    
    public var handle: UIView
    
    public var initialOrigin: CGPoint? = nil
    
    init() {
        handle = UIView()
        handle.translatesAutoresizingMaskIntoConstraints = false
        handle.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        handle.layer.cornerRadius = 4.0
        
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        
        self.addSubview(handle)
        
        handle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        handle.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        handle.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).isActive = true
        handle.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SplitStackViewOrganizer {
    let view: UIView
    var ratio: CGFloat = .zero
    var minRatio: CGFloat = .zero
    var constraint: NSLayoutConstraint? = nil
}

extension SplitStackViewOrganizer: Equatable {
    
}

class SplitStackView: UIView {
    private let stack = UIStackView()
    
    public var views = [SplitStackViewOrganizer]()
    public var handles = [SplitStackViewHandle]()
    
    public var handleHeight: CGFloat = 18.0
    public var minimumHeightRatio: CGFloat = 0.0
    
    init() {
        super.init(frame: .zero)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        self.addSubview(stack)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollview]|", options: .alignAllCenterY, metrics: nil, views: ["scrollview": stack]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addView(_ view: UIView, ratio: CGFloat = 0.5, minRatio: CGFloat = 0.0) {
        precondition(ratio >= 0.0, "Ratio must be greater than zero")
        precondition(ratio <= 1.0, "Ratio must be less than one")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let organizer = SplitStackViewOrganizer(view: view, ratio: ratio, minRatio: minRatio, constraint: nil)
        views.append(organizer)
        
        if views.count % 2 == 0 {
            let handle = SplitStackViewHandle()
            handle.translatesAutoresizingMaskIntoConstraints = false
            handles.append(handle)
            stack.addArrangedSubview(handle)
            handle.heightAnchor.constraint(equalToConstant: handleHeight).isActive = true
            
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
            handle.addGestureRecognizer(gesture)
        }
        
        stack.addArrangedSubview(organizer.view)
        
        self.assignRatios(newRatio: self.ratio(given: ratio, for: organizer), for: views.count - 1)
        self.setRatios()
    }
    
    private func setRatios() {
        let handleConstant = CGFloat(self.handles.count) * handleHeight
        for (i, view) in views.enumerated() {
            print("$!", i, "setting height anchor to", view.ratio, -handleConstant)
            views[i].constraint?.isActive = false
            views[i].constraint = nil
            // using greaterThanOrEqual to ignore roudning errors
            views[i].constraint = NSLayoutConstraint(item: views[i].view, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: stack, attribute: .height, multiplier: view.ratio, constant: view.ratio > 0.0 ? -handleConstant: 0.0)
            views[i].constraint?.isActive = true
        }
    }
    
    private func ratio(given ratio: CGFloat, for organizer: SplitStackViewOrganizer)->CGFloat {
        if views.count == 1 {
            return 1.0
        }
        
        var minRatio: CGFloat = 0.0
        for view in views {
            if view == organizer {
                continue
            }
            minRatio += max(minimumHeightRatio, view.minRatio)
        }
        if ratio >= 1.0 {
            return 1.0 - minRatio
        }
        
        let curMinRatio = max(minimumHeightRatio, organizer.minRatio)
        
        if ratio <= 0.0 {
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
        let secondRatio = 1.0 - newRatio
        for (i, _) in views.enumerated() {
            if i == index {
                views[i].ratio = newRatio
                continue
            }
            views[i].ratio = secondRatio
        }
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        guard let handle = sender.view as? SplitStackViewHandle else {
            return
        }
        
        guard let handleIndex = handles.firstIndex(of: handle) else {
            return
        }
        
        let organizer = views[handleIndex]
        
        switch sender.state {
        case .began:
            print("$! setting frames", organizer.view.frame)
            handle.initialOrigin = handle.frame.origin
            break
        case .changed:
            let newPoint = handle.initialOrigin!.y + sender.translation(in: handle).y
            let curPoint = handle.frame.origin.y
            print("$! Total diff", newPoint, curPoint, organizer.ratio)
            var ratio: CGFloat = 0.0
            if curPoint != 0 {
                ratio = organizer.ratio * (newPoint/curPoint)
            }
            views[handleIndex].ratio = self.ratio(given: max(ratio, views[handleIndex].minRatio), for: views[handleIndex])
            self.assignRatios(newRatio: views[handleIndex].ratio, for: handleIndex)
            
            
            UIView.animate(withDuration: 0.01) {
                self.setRatios()
                self.layoutIfNeeded()
            }
            
            break
        default:
            break
        }
    }
    
}
