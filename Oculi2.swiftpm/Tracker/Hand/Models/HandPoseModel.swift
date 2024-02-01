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
    /// One finger pointing: 􀤹.
    case point = "Point"
    /// Twp fingers together.
    case twoFinger = "Two Finger Point"
    /// No pose detected.
    case none = "None"

    var title: String {
        switch self {
        case .pinch:
            "Pinch Your Fingers"
        case .point:
            "Point"
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
        case .point:
            "Point your dominant index fingers slightly up at the sky."
        case .twoFinger:
            "Point your dominant index and middle fingers slightly up at the sky."
        case .none:
            "None"
        }
    }

    var nextPose: HandPose? {
        switch self {
        case .pinch:
            return .point
        case .point:
            return .twoFinger
        default:
            return nil
        }
    }
}

struct HandPoseMargins {
    static private let Buffer: CGFloat = 0.075
    static private(set) var FlatMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var PinchMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var PointMargins: [CGFloat] = Array(repeating: 1, count: 5)
    static private(set) var TwoPointMargins: [CGFloat] = Array(repeating: 1, count: 5)

    public static func UpdateMargins(for pose: HandPose, margins: [CGFloat]) {
        switch pose {
        case .pinch:
            PinchMargins = margins
        case .point:
            PointMargins = margins
        case .twoFinger:
            TwoPointMargins = margins
        case .none:
            return
        }
    }

    /// Checks if a value is within the margin calculated at calibration.
    public static func Within(margin: CGFloat, value: CGFloat) -> Bool {
        return ((margin - Buffer)...(margin + Buffer)).contains(value)
    }
}

class HandPoseModel {
    static func predictHandPose(from hand: Hand) -> HandPose {
        func tipPointsAllWithin(margins: [CGFloat]) -> Bool {
            return hand.tipDistances.enumerated().allSatisfy {
                HandPoseMargins.Within(
                    margin: margins[$0],
                    value: $1
                )
            }
        }

        func checkPinchPose(hand: Hand) -> Bool {
            tipPointsAllWithin(margins: HandPoseMargins.PinchMargins)
        }

        func checkPointPose(hand: Hand) -> Bool {
            tipPointsAllWithin(margins: HandPoseMargins.PointMargins)
        }

        // Method for checking the 'twoFingerPoint' pose.
        func checkTwoFingerPointPose(hand: Hand) -> Bool {
            tipPointsAllWithin(margins: HandPoseMargins.TwoPointMargins)
        }

        if checkPinchPose(hand: hand) {
            return .pinch
        }

        if checkPointPose(hand: hand) {
            return .point
        }

        if checkTwoFingerPointPose(hand: hand) {
            return .twoFinger
        }

        return .none
    }
}
