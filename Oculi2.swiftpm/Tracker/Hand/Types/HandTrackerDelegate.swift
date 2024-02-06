//
//  HandTrackerDelegate.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import Foundation
import Vision

protocol HandTrackerDelegate {
    func handDidChange(to value: Hand)
    func handPoseDidChange(to value: HandPose)
    func handPoseConfidenceChanged(to values: [Finger: VNConfidence])
}
