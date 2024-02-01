//
//  HandTrackerState.swift
//
//
//  Created by Evan Crow on 1/31/24.
//

import Foundation

enum HandTrackerState {
    case none
    case possiblePose(handPose: HandPose, amount: Int)
    case confirmedPose(handPose: HandPose)

    var label: String {
        switch self {
        case .none:
            return "None"
        case .possiblePose(let handPose, let amount):
            return "Possibly: \(handPose.rawValue) Detected: \(amount)"
        case .confirmedPose(let handPose):
            return handPose.rawValue
        }
    }
}
