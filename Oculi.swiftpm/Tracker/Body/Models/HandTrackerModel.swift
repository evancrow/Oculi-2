//
//  HandTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Foundation
import SwiftUI
import Vision

class HandTrackerModel: ObservableObject {
    private var interactionManager: InteractionManager!
    
    @Published public private(set) var quality: VisionQualityState = .NotDetected
    @Published public private(set) var currentHandPose: HandPose = .none
    
    // MARK: - config
    public func config(interactionManager: InteractionManager) {
        self.interactionManager = interactionManager
    }
}

// MARK: - HandTrackerDelegate
extension HandTrackerModel: HandTrackerDelegate {
    func handPoseDidChange(to value: HandPose) {
        self.currentHandPose = value
    }

    func handPoseConfidenceChanged(
        thumb: VNConfidence,
        index: VNConfidence,
        middle: VNConfidence,
        ring: VNConfidence,
        litte: VNConfidence
    ) {
        let highQuality: VNConfidence = 0.5
        let lowQuality: VNConfidence = 0.3

        if thumb > highQuality,
            index > highQuality,
            middle > highQuality,
            ring > highQuality,
            litte > highQuality
        {
            quality = .Detected
        } else if thumb > lowQuality,
            index > lowQuality,
            middle > lowQuality,
            ring > lowQuality,
            litte > lowQuality
        {
            quality = .DetectedLowQuality
        } else {
            quality = .NotDetected
        }
    }
}
