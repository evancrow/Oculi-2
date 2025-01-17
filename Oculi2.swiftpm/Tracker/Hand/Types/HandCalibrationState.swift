//
//  HandCalibrationState.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import Foundation

enum HandCalibrationState: Equatable {
    case NotCalibrated
    case Calibrated
    case CalibratingChangePose(pose: HandPose)
    case CalibratingPose(pose: HandPose)
    case Failed
}
