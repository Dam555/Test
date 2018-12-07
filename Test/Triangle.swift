//
//  File.swift
//  Test
//
//  Created by Damjan on 07/12/2018.
//  Copyright © 2018 Genesis Mobile. All rights reserved.
//

import Foundation

struct Triangle {
    let sideA: Double
    let sideB: Double
    let sideC: Double
    let surface: Double
    let date: Date
    
    init(sideA: Double, sideB: Double, sideC: Double) {
        self.sideA = sideA
        self.sideB = sideB
        self.sideC = sideC
        
        let cosGamma = (pow(sideA, 2.0) + pow(sideB, 2.0) - pow(sideC, 2.0)) / (2.0 * sideA * sideB)
        let gamma = acos(cosGamma)
        let heightA = sideB * sin(gamma)
        surface = (sideA * heightA) / 2.0
        
        date = Date()
    }
}
