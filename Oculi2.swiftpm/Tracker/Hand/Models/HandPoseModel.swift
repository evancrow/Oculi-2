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
    /// Unable to detect a pose.
    case unknown = "Unknown"
}

struct HandPoseDefaults {
    static let FlatMargins: [CGFloat] = [0.23, 0.08, 0.09, 0.13]
    static let FlatMarginMinimums: [CGFloat] = [0.1]

    static let PinchMargins: [CGFloat] = [0.05, 0.03]
    static let PointMargins: [CGFloat] = [0.3]
    static let TwoPointMargins: [CGFloat] = [0.15, 0.08, 0.35]
}

class HandPoseModel {
    static func calibrate() {
        
    }
    
    static func predictHandPose(from hand: Hand) -> HandPose {
        // Check for a flat hand.
        if hand.tipDistances.enumerated().allSatisfy({ $1 < HandPoseDefaults.FlatMargins[$0] })
            && hand.tipDistances[0] > HandPoseDefaults.FlatMarginMinimums[0]
        {
            return .flat
        }

        // Check for pinch.
        if hand.tipDistances[0] < HandPoseDefaults.PinchMargins[0]
            && hand.tipDistances[1] > HandPoseDefaults.PinchMargins[1]
        {
            return .pinch
        }

        // Check for pointing.
        if hand.tipDistances[0] > HandPoseDefaults.PointMargins[0]
            && hand.tipDistances[1] > HandPoseDefaults.PointMargins[0]
        {
            return .point
        }

        // Check for two fingers pointing.
        if hand.tipDistances[0] > HandPoseDefaults.TwoPointMargins[0]
            && hand.tipDistances[1] < HandPoseDefaults.TwoPointMargins[1]
            && hand.tipDistances[2] > HandPoseDefaults.TwoPointMargins[2]
        {
            return .twoFinger
        }

        return .none
    }
}
