//
//  HandPoseModel.swift
//
//
//  Created by Evan Crow on 1/14/24.
//

import Foundation

enum HandPose: String, CaseIterable {
    /// Open hand: 􀉻.
    case flat = "Flat"
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
        case .flat:
            "Flat Hand"
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
        case .flat:
            "Hold your dominant hand up, palm facing the camera. Keep your fingers together, like you’re saying stop."
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
        case .flat:
            return .pinch
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
    static private let Buffer: CGFloat = 0.055
    static private(set) var FlatMargins: [CGFloat] = [0.23, 0.08, 0.09, 0.13]
    static let FlatMarginMinimums: [CGFloat] = [0.1]

    static private(set) var PinchMargins: [CGFloat] = [0.05, 0.03]
    static private(set) var PointMargins: [CGFloat] = [0.3]
    static private(set) var TwoPointMargins: [CGFloat] = [0.15, 0.08, 0.35]

    private static func updateFlatMargins(margins: [CGFloat]) {
        FlatMargins = margins
    }

    private static func updatePinchMargins(margins: [CGFloat]) {
        PinchMargins = margins
    }

    private static func updatePointMargins(margins: [CGFloat]) {
        PointMargins = margins
    }

    private static func updateTwoPointMargins(margins: [CGFloat]) {
        TwoPointMargins = margins
    }

    public static func UpdateMargins(for pose: HandPose, margins: [CGFloat]) {
        switch pose {
        case .flat:
            updateFlatMargins(margins: margins.map { $0 + Buffer })
        case .pinch:
            var margins = margins
            margins[0] += Buffer
            margins[1] -= Buffer

            updatePinchMargins(margins: margins)
        case .point:
            updatePointMargins(margins: margins.map { $0 - Buffer })
        case .twoFinger:
            var margins = margins
            margins[0] -= Buffer
            margins[1] += Buffer
            margins[2] -= Buffer

            updateTwoPointMargins(margins: margins)
        case .none:
            return
        }
    }
}

class HandPoseModel {
    static func predictHandPose(from hand: Hand) -> HandPose {
        // Check for a flat hand.
        if hand.tipDistances.enumerated().allSatisfy({ $1 < HandPoseMargins.FlatMargins[$0] })
            && hand.tipDistances[0] > HandPoseMargins.FlatMarginMinimums[0]
        {
            return .flat
        }

        // Check for pinch.
        if hand.tipDistances[0] < HandPoseMargins.PinchMargins[0]
            && hand.tipDistances[1] > HandPoseMargins.PinchMargins[1]
        {
            return .pinch
        }

        // Check for pointing.
        if hand.tipDistances[0] > HandPoseMargins.PointMargins[0]
            && hand.tipDistances[1] > HandPoseMargins.PointMargins[0]
        {
            return .point
        }

        // Check for two fingers pointing.
        if hand.tipDistances[0] > HandPoseMargins.TwoPointMargins[0]
            && hand.tipDistances[1] < HandPoseMargins.TwoPointMargins[1]
            && hand.tipDistances[2] > HandPoseMargins.TwoPointMargins[2]
        {
            return .twoFinger
        }

        return .none
    }
}
