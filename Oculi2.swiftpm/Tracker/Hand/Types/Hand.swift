//
//  File.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import Foundation
import Vision

struct Hand {
    // MARK: - Tips
    let tips: [Finger: CGPoint]
    let allTips: [CGPoint]
    let tipDistances: [CGFloat]

    func tipLocation(finger: Finger) -> CGPoint {
        return tips[finger]!
    }

    // MARK: - Knuckles
    let knuckles: [Finger: CGPoint]
    let allKnuckles: [CGPoint]
    let knuckleDistances: [CGFloat]

    func knuckleLocation(finger: Finger) -> CGPoint {
        return knuckles[finger]!
    }

    // MARK: - init
    init(tips: [Finger: CGPoint], knuckles: [Finger: CGPoint]) {
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
        self.allTips = Array(tips.values)
        self.tipDistances = createDistances(joint: tips)

        // Knuckles
        self.knuckles = knuckles
        self.allKnuckles = Array(knuckles.values)
        self.knuckleDistances = createDistances(joint: knuckles)
    }
}
