//
//  CalibrationPageDefaults.swift
//
//
//  Created by Evan Crow on 1/28/24.
//

import Foundation

struct CalibrationPageDefaults {
    static let SetUpTime = 5
    static let CalibrationTime = 5
    static var TotalTimePerPose: Int {
        SetUpTime + CalibrationTime
    }
}
