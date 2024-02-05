//
//  HandPoseCalibrationModel.swift
//
//
//  Created by Evan Crow on 1/27/24.
//

import Combine
import Foundation

struct HandTrackerCalibrationDefaults {
    static let SetUpTime = 6
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
        func standardDeviation(of array: [CGFloat]) -> CGFloat {
            let length = CGFloat(array.count)
            let avg = array.reduce(0, +) / length
            let sumOfSquaredAvgDiff = array.map { pow($0 - avg, 2.0) }.reduce(0, +)
            return sqrt(sumOfSquaredAvgDiff / length)
        }

        func removeOutliers(from distances: [CGFloat]) -> [CGFloat] {
            guard distances.count > 4 else { return distances }

            let sortedDistances = distances.sorted()
            let q1 = sortedDistances[sortedDistances.count / 4]
            let q3 = sortedDistances[(3 * sortedDistances.count) / 4]
            let iqr = q3 - q1
            let lowerBound = q1 - 1.5 * iqr
            let upperBound = q3 + 1.5 * iqr

            return distances.filter { distance in
                distance >= lowerBound && distance <= upperBound
            }
        }

        for pose in HandPose.allCases where pose != .none {
            let dataForPose = calibrationData[pose, default: []]
            let filteredDataForPose = dataForPose.map { removeOutliers(from: $0.tipDistances) }

            guard !filteredDataForPose.isEmpty else {
                calibrationState = .Failed
                return
            }

            let totalTipDistances = filteredDataForPose.reduce(
                into: Array(repeating: 0.0, count: 4)
            ) { partialResult, currentResult in
                for index in 0..<4 {
                    partialResult[index] += currentResult[index]
                }
            }

            let totalTipDistancesAverage: [CGFloat] = totalTipDistances.map {
                $0 / CGFloat(filteredDataForPose.count)
            }
            let sd = standardDeviation(of: totalTipDistancesAverage)

            guard totalTipDistancesAverage.allSatisfy({ $0 > 0 }) else {
                calibrationState = .Failed
                return
            }

            HandPoseMargins.UpdateMargins(
                for: pose, margins: totalTipDistancesAverage, standardDeviation: sd)
        }

        if calibrationState != .Failed {
            calibrationState = .Calibrated
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
