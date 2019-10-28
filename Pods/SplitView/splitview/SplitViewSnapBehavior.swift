//
//  SplitViewSnapBehavior.swift
//  SplitView
//
//  Created by Zachary Gorak on 9/3/19.
//  Copyright © 2019 Zac Gorak. All rights reserved.
//

import Foundation

/// A structure that contains a snap point that is percentage based and a tolerance for when to snap
public struct SplitViewSnapPoint: Equatable {
    /// The point at which to snap
    public let percentage: CGFloat
    /// The amount of range to induce a snap effects
    public let tolerance: CGFloat
    
    /// The global default tolernace
    public static var defaultTolerance:CGFloat = 0.04
}

/// The specefied snap behavior
public enum SplitViewSnapBehavior: Equatable {
    /// Snap every 25% (0%, 25%, 50%, 75%, 80%) with the default tolerance
    case quarter
    /// Snap every 33% (0%, 33%, 66%, 100%) with a the default tolerance
    case third
    /// Snap at a given percentage and tolerance
    case custom(percentage: CGFloat, tolerance: CGFloat)
    /// Snap at a given SnapPoint
    case withPoint(SplitViewSnapPoint)
    /// Snap at the given SnapPoints
    case withPoints([SplitViewSnapPoint])
    
    /// The points at which to snap
    var snapPoints: [SplitViewSnapPoint] {
        switch self {
        case .quarter:
            return [SplitViewSnapPoint(percentage: 0.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.25, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.50, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 0.75, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0, tolerance: SplitViewSnapPoint.defaultTolerance)]
        case .third:
            return [SplitViewSnapPoint(percentage: 0.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0/3.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 2.0/3.0, tolerance: SplitViewSnapPoint.defaultTolerance),
            SplitViewSnapPoint(percentage: 1.0, tolerance: SplitViewSnapPoint.defaultTolerance)
            ]
        case .withPoint(let point):
            return [point]
        case .withPoints(let points):
            return points
        case .custom(let percentage, let tolerance):
            return [SplitViewSnapPoint(percentage: percentage, tolerance: tolerance)]
        }
    }
}
