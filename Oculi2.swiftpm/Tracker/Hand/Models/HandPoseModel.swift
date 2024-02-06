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
    /// Twp fingers together.
    case twoFinger = "Two Finger Point"
    /// No pose detected.
    case none = "None"

    var title: String {
        switch self {
        case .pinch:
            "Pinch Your Fingers"
        case .twoFinger:
            "Point Two Fingers"
        case .none:
            "None"
        }
    }

    var setUpInstruction: String {
        switch self {
        case .pinch:
            "Pinch both your dominant thumb and your index finger together."
        case .twoFinger:
            "Point your dominant index and middle fingers slightly up at the sky."
        case .none:
            "None"
        }
    }

    var nextPose: HandPose? {
        switch self {
        case .pinch:
            return .twoFinger
        default:
            return nil
        }
    }
}

struct HandPoseMargins {
    static private let Buffer: CGFloat = 0.075
    static private(set) var PinchMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var PinchMarginsSD: CGFloat = 0
    static private(set) var TwoPointMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var TwoPointMarginsSD: CGFloat = 0

    public static func UpdateMargins(
        for pose: HandPose, margins: [CGFloat], standardDeviation: CGFloat
    ) {
        switch pose {
        case .pinch:
            PinchMargins = margins
            PinchMarginsSD = standardDeviation
        case .twoFinger:
            TwoPointMargins = margins
            TwoPointMarginsSD = standardDeviation
        case .none:
            return
        }
    }

    /// Checks if a value is within the margin calculated at calibration.
    public static func Within(margin: CGFloat, value: CGFloat, sd: CGFloat, isCritical: Bool)
        -> Bool
    {
        let buffer = isCritical ? (Buffer + sd * 0.25) : (Buffer + sd * 0.75)
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

        func checkTwoFingerPointPose(hand: Hand) -> Bool {
            // Assuming 1 is the index for index-middle distance.
            return tipPointsAllWithin(
                margins: HandPoseMargins.TwoPointMargins,
                sds: HandPoseMargins.TwoPointMarginsSD,
                criticalIndex: 1
            )
        }

        if checkPinchPose(hand: hand) {
            return .pinch
        }

        if checkTwoFingerPointPose(hand: hand) {
            return .twoFinger
        }

        return .none
    }
}
