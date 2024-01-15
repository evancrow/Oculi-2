//
//  HandTrackerDelegate.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import Foundation
import Vision

protocol HandTrackerDelegate {
    func handPoseDidChange(to value: HandPose)
    func handPoseConfidenceChanged(
        thumb: VNConfidence,
        index: VNConfidence,
        middle: VNConfidence,
        ring: VNConfidence,
        litte: VNConfidence
    )
}
