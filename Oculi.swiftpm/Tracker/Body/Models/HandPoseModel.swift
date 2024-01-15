//
//  HandPoseModel.swift
//
//
//  Created by Evan Crow on 1/14/24.
//

import Foundation

enum HandPose {
    /// Open hand: 􀉻.
    case flat
    /// Thumb and index fingers pinched together.
    case pinch
    /// One finger pointing: 􀤹.
    case point
    /// Twp fingers together.
    case twoFinger
    /// No pose detected.
    case none
    /// Unable to detect a pose.
    case unknown
}

class HandPoseModel {
    static func predictPoseFromTipPoints(
        thumb: CGPoint,
        index: CGPoint,
        middle: CGPoint,
        ring: CGPoint,
        little: CGPoint
    ) -> HandPose {
        return .none
    }
}
