//
//  DetailController.swift
//  Test
//
//  Created by Damjan on 07/12/2018.
//  Copyright © 2018 Genesis Mobile. All rights reserved.
//

import UIKit

class DetailController: UIViewController {

    /// Views and layout constraints.
    @IBOutlet var triangleSurfaceLabel: UILabel!
    
    /// Triangle surface to display.
    var triangleSurface: Double = 0.0
    
    /// View did load.
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelButtonDidTouchUpInside(_:)))
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        
        triangleSurfaceLabel.text = numberFormatter.string(from: NSNumber(value: triangleSurface))
    }
    
    /// Cancel button did touch up inside.
    @objc func cancelButtonDidTouchUpInside(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
