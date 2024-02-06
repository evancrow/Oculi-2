//
//  File.swift
//
//
//  Created by Evan Crow on 1/26/24.
//

import Foundation
import Vision

enum Finger: CaseIterable {
    case thumb
    case index
    case middle
    case ring
    case little

    func toJointName() -> VNHumanHandPoseObservation.JointName? {
        switch self {
        case .thumb:
            return .thumbTip
        case .index:
            return .indexTip
        case .middle:
            return .middleTip
        case .ring:
            return .ringTip
        case .little:
            return .littleTip
        }
    }
}
