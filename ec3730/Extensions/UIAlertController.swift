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
    public func addActionSheetForiPad(sourceView _view: UIView? = nil, sourceRect _rect: CGRect? = nil, permittedArrowDirections _arrowDirections: UIPopoverArrowDirection? = nil) {
        let useView = (_view ?? self.view) as UIView
        let useRect = (_rect ?? CGRect(x: useView.bounds.midX, y: useView.bounds.midY, width: 0, height: 0)) as CGRect
        let useArrows = (_arrowDirections ?? []) as UIPopoverArrowDirection
        
        self.popoverPresentationController?.sourceView = useView
        self.popoverPresentationController?.sourceRect = useRect
        self.popoverPresentationController?.permittedArrowDirections = useArrows
    }
}
