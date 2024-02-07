//
//  HandPoseModel.swift
//
//
//  Created by Evan Crow on 1/14/24.
//

import Foundation

enum HandPose: String, CaseIterable {
    /// Thumb and index fingers pinched together.
    case pinch = "Pinch"
    /// No pose detected.
    case none = "None"

    var title: String {
        switch self {
        case .pinch:
            "Pinch Your Fingers"
        case .none:
            "None"
        }
    }

    var setUpInstruction: String {
        switch self {
        case .pinch:
            "Pinch both your dominant thumb and your index finger together."
        case .none:
            "None"
        }
    }

    var nextPose: HandPose? {
        nil
    }
}

struct HandPoseMargins {
    static private(set) var PinchMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var PinchMarginsSD: CGFloat = 0

    public static func UpdateMargins(
        for pose: HandPose, margins: [CGFloat], standardDeviation: CGFloat
    ) {
        switch pose {
        case .pinch:
            PinchMargins = margins
            PinchMarginsSD = standardDeviation
        case .none:
            return
        }
    }

    public static func Buffer(sd: CGFloat, isCritical: Bool)
        -> CGFloat
    {
        return isCritical
            ? (HandTrackerDefaults.PoseBuffer + sd * HandTrackerDefaults.CriticalPointSDWeight)
            : (HandTrackerDefaults.PoseBuffer + sd * HandTrackerDefaults.NonCriticalPointSDWeight)
    }

    /// Checks if a value is within the margin calculated at calibration.
    public static func Within(margin: CGFloat, value: CGFloat, sd: CGFloat, isCritical: Bool)
        -> Bool
    {
        let buffer = Buffer(sd: sd, isCritical: isCritical)
        return ((margin - buffer)...(margin + buffer)).contains(value)
    }
}

class HandPoseModel {
    static func predictHandPose(from hand: Hand) -> HandPose {
        func tipPointsAllWithin(margins: [CGFloat], sds: CGFloat, criticalIndex: Int) -> Bool {
            return hand.tipDistances.enumerated().allSatisfy { index, distance in
                let isCritical = index == criticalIndex
                return HandPoseMargins.Within(
                    margin: margins[index],
                    value: distance,
                    sd: sds,
                    isCritical: isCritical
                )
            }
        }

        func checkPinchPose(hand: Hand) -> Bool {
            // Assuming 0 is the index for thumb-index distance.
            return tipPointsAllWithin(
                margins: HandPoseMargins.PinchMargins,
                sds: HandPoseMargins.PinchMarginsSD,
                criticalIndex: 0
            )
        }

        if checkPinchPose(hand: hand) {
            return .pinch
        }

        return .none
    }
}
