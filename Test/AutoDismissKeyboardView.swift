//
//  AutoDismissKeyboardView.swift
//  Test
//
//  Created by Damjan on 07/12/2018.
//  Copyright © 2018 Genesis Mobile. All rights reserved.
//

import Foundation
import UIKit

class AutoDismissKeyboardView: UIView {

    /// Dismiss keyboard when touches have begun.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        var view: UIView? = self
        while view != nil {
            view?.endEditing(true)
            view = view?.superview
        }
    }
}
