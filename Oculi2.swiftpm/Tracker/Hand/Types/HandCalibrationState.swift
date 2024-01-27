//
//  HandCalibrationState.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import Foundation

enum HandCalibrationState {
    case NotCalibrated
    case Calibrated
    case CalibratingChangePose(pose: HandPose)
    case CalibratingPose(pose: HandPose)
}
