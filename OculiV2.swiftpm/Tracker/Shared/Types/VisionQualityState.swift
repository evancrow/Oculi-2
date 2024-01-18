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
}
