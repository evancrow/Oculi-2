//
//  VisionQualityState.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import Foundation

public enum VisionQualityState: String {
    case Detected = "Detected"
    case DetectedLowQuality = "Detected (Low Quality)"
    case NotDetected = "No Detection"
    
    var level: Int {
        switch self {
        case .Detected:
            2
        case .DetectedLowQuality:
            1
        case .NotDetected:
            0
        }
    }
    
    init(level: Int) {
        if level == 2 {
            self = .Detected
        } else if level == 1 {
            self = .DetectedLowQuality
        } else {
            self = .NotDetected
        }
    }
}
