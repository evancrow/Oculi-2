//
//  File.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import Foundation

struct HandTrackerCalibrationDefaults {
    static let SetUpTime: Double = 5
    static let CalibrationTime: Double = 5
    static let CalibrationOrder: [HandPose] = [.flat, .pinch, .point, .twoFinger]
}

class HandPoseCalibrationModel: ObservableObject {
    @Published public private(set) var calibrationState: HandCalibrationState = .NotCalibrated

    private var poseInstructionTimer: Timer?
    private var poseCalibrationTimer: Timer?

    func startCalibration() {
        changeCalibrationPose(toPoseAtIndex: 0)
    }

    private func changeCalibrationPose(toPoseAtIndex index: Int) {
        calibrationState = .CalibratingChangePose(
            pose: HandTrackerCalibrationDefaults.CalibrationOrder[index])

        poseInstructionTimer = Timer.scheduledTimer(
            withTimeInterval: HandTrackerCalibrationDefaults.SetUpTime,
            repeats: false
        ) { _ in
            self.calibratePose(atIndex: index)
        }
    }

    private func calibratePose(atIndex index: Int) {
        calibrationState = .CalibratingPose(
            pose: HandTrackerCalibrationDefaults.CalibrationOrder[index])

        if index < HandTrackerCalibrationDefaults.CalibrationOrder.count - 1 {
            poseCalibrationTimer = Timer.scheduledTimer(
                withTimeInterval: HandTrackerCalibrationDefaults.CalibrationTime,
                repeats: false
            ) { _ in
                self.changeCalibrationPose(toPoseAtIndex: index + 1)
            }
        }
    }
}
