//
//  HandPoseCalibrationModel.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import Combine
import Foundation

struct HandTrackerCalibrationDefaults {
    static let SetUpTime = 5
    static let CalibrationTime = 5
    static var TotalTimePerPose: Int {
        SetUpTime + CalibrationTime
    }
}

class HandPoseCalibrationModel: ObservableObject {
    @Published public private(set) var timeRemaining: Int = HandTrackerCalibrationDefaults
        .TotalTimePerPose
    @Published public private(set) var calibrationState: HandCalibrationState = .NotCalibrated

    private let timer: TimerModel = TimerModel(
        timerDuration: HandTrackerCalibrationDefaults.TotalTimePerPose
    )
    private var timerListener: AnyCancellable?
    private var calibrationData: [HandPose: [Hand]] = [:]

    // MARK: - State
    func startCalibration(for pose: HandPose) {
        calibrationState = .CalibratingChangePose(pose: pose)
        timer.start()
        timerListener = timer.$timeRemaining.sink { [weak self] remaining in
            DispatchQueue.main.async {
                self?.timeRemaining = remaining

                if case .CalibratingChangePose(pose) = self?.calibrationState,
                    remaining <= HandTrackerCalibrationDefaults.TotalTimePerPose
                        - HandTrackerCalibrationDefaults.SetUpTime
                {
                    self?.calibratePose(pose)
                } else if case .CalibratingPose(pose) = self?.calibrationState,
                    remaining <= 0
                {
                    if let nextPose = pose.nextPose {
                        self?.startCalibration(for: nextPose)
                    } else {
                        self?.finishCalibration()
                    }
                }
            }
        }
    }

    private func calibratePose(_ pose: HandPose) {
        calibrationData[pose] = []
        calibrationState = .CalibratingPose(pose: pose)
    }

    func finishCalibration() {
        calibrationState = .Calibrated

        for pose in HandPose.allCases where pose != .none {
            let dataForPose = calibrationData[pose, default: []]
            let totalTipDistances = dataForPose.reduce(
                into: Array(repeating: 0, count: 4)
            ) { partialResult, currentResult in
                for index in 0..<4 {
                    partialResult[index] += currentResult.tipDistances[index]
                }
            }
            let totalTipDistancesAverage: [CGFloat] = totalTipDistances.map {
                $0 / CGFloat(dataForPose.count)
            }

            guard totalTipDistancesAverage.allSatisfy({ $0 > 0 }) else {
                calibrationState = .Failed
                return
            }

            HandPoseMargins.UpdateMargins(for: pose, margins: totalTipDistancesAverage)
        }
    }

    func skipCalibration() {
        calibrationState = .NotCalibrated
    }

    // MARK: - Data
    func receivedNewHand(data: Hand) {
        if case .CalibratingPose(let pose) = calibrationState {
            calibrationData[pose, default: []].append(data)
        }
    }
}
