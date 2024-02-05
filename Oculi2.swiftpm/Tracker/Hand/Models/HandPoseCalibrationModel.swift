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
        for pose in HandPose.allCases where pose != .none {
            let dataForPose = calibrationData[pose, default: []]

            // Function to remove outliers for a given distance array.
            func removeOutliers(from distances: [CGFloat]) -> [Bool] {
                let sortedDistances = distances.sorted()
                let q1 = sortedDistances[sortedDistances.count / 4]
                let q3 = sortedDistances[(3 * sortedDistances.count) / 4]
                let iqr = q3 - q1
                let lowerBound = q1 - 1.5 * iqr
                let upperBound = q3 + 1.5 * iqr

                return distances.map { distance in
                    distance >= lowerBound && distance <= upperBound
                }
            }

            // Determine which data points are not outliers for each tip distance.
            var includeHand = Array(repeating: true, count: dataForPose.count)
            for index in 0..<4 {
                let distanceFlags = removeOutliers(from: dataForPose.map { $0.tipDistances[index] })
                for (i, flag) in distanceFlags.enumerated() {
                    includeHand[i] = includeHand[i] && flag
                }
            }

            // Filter dataForPose based on includeHand flags.
            let filteredDataForPose = zip(dataForPose, includeHand).compactMap { $1 ? $0 : nil }

            // Proceed with calculation only if there's enough data after filtering.
            guard !filteredDataForPose.isEmpty else {
                calibrationState = .Failed
                return
            }

            // Calculate total and average tip distances for filtered data.
            let totalTipDistances = filteredDataForPose.reduce(
                into: Array(repeating: 0, count: 4)
            ) { partialResult, currentResult in
                for index in 0..<4 {
                    partialResult[index] += currentResult.tipDistances[index]
                }
            }
            let totalTipDistancesAverage: [CGFloat] = totalTipDistances.map {
                $0 / CGFloat(filteredDataForPose.count)
            }

            guard totalTipDistancesAverage.allSatisfy({ $0 > 0 }) else {
                calibrationState = .Failed
                return
            }

            HandPoseMargins.UpdateMargins(for: pose, margins: totalTipDistancesAverage)
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
