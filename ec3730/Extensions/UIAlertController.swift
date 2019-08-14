//
//  UIAlertController.swift
//  ec3730
//
//  Created by Zachary Gorak on 8/12/19.
//  Copyright © 2019 Zachary Gorak. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    /**
     - seealso: https://stackoverflow.com/a/54932223/193772
     */
    public func addActionSheetForiPad(sourceView aView: UIView? = nil, sourceRect rect: CGRect? = nil, permittedArrowDirections arrowDirections: UIPopoverArrowDirection? = nil) {
        let useView = (aView ?? view) as UIView
        let useRect = (rect ?? CGRect(x: useView.bounds.midX, y: useView.bounds.midY, width: 0, height: 0)) as CGRect
        let useArrows = (arrowDirections ?? []) as UIPopoverArrowDirection

        popoverPresentationController?.sourceView = useView
        popoverPresentationController?.sourceRect = useRect
        popoverPresentationController?.permittedArrowDirections = useArrows
    }
}
