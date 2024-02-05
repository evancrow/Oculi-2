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
    static private let Buffer: CGFloat = 0.055
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
    public static func Within(margin: CGFloat, value: CGFloat, standardDeviation: CGFloat) -> Bool {
        let dynamicBuffer = Buffer + standardDeviation * 0.5  // Adjust this factor as needed
        return ((margin - dynamicBuffer)...(margin + dynamicBuffer)).contains(value)
    }
}

class HandPoseModel {
    static func predictHandPose(from hand: Hand) -> HandPose {
        func tipPointsAllWithin(margins: [CGFloat], standardDeviation: CGFloat) -> Bool {
            return hand.tipDistances.enumerated().allSatisfy {
                HandPoseMargins.Within(
                    margin: margins[$0],
                    value: $1,
                    standardDeviation: standardDeviation
                )
            }
        }

        func checkPinchPose(hand: Hand) -> Bool {
            tipPointsAllWithin(
                margins: HandPoseMargins.PinchMargins,
                standardDeviation: HandPoseMargins.PinchMarginsSD)
        }

        // Method for checking the 'twoFingerPoint' pose.
        func checkTwoFingerPointPose(hand: Hand) -> Bool {
            tipPointsAllWithin(
                margins: HandPoseMargins.TwoPointMargins,
                standardDeviation: HandPoseMargins.TwoPointMarginsSD)
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
