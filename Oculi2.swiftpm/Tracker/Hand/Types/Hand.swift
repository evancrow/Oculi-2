//
//  File.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import Foundation
import Vision

struct Hand {
    let tips: [Finger: CGPoint]
    let confidence: [Finger: VNConfidence]
    let tipDistances: [CGFloat]

    func tipLocation(finger: Finger) -> CGPoint {
        return tips[finger]!
    }

    // MARK: - init
    init(tips: [Finger: CGPoint], confidence: [Finger: VNConfidence]) {
        func createDistances(joint: [Finger: CGPoint]) -> [CGFloat] {
            return [
                joint[.thumb]!.calculateDistance(to: joint[.index]!),
                joint[.index]!.calculateDistance(to: joint[.middle]!),
                joint[.middle]!.calculateDistance(to: joint[.ring]!),
                joint[.ring]!.calculateDistance(to: joint[.little]!),
            ]
        }

        // Tips
        self.tips = tips
        self.confidence = confidence
        self.tipDistances = createDistances(joint: tips)
    }
}
