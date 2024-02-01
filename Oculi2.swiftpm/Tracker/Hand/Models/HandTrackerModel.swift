//
//  HandTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Foundation
import SwiftUI
import Vision

struct HandTrackerDefaults {
    /// Number of times a pose must be detected before it is confirmed to be active.
    static let ConfirmationAmount = 3

    static let MaximumPinchSeperationTime: Double = 1
    /// Duration (in seconds) of how long a pinch must be before it is confirmed to be "long".
    /// Similar to a long tap.
    static let LongPinchDuration = 2

    static let MinimumScrollDelta: CGFloat = 30
}

class HandTrackerModel: ObservableObject {
    // MARK: - Published
    @Published public private(set) var quality: VisionQualityState = .NotDetected
    @Published public private(set) var currentHand: Hand?
    @Published public private(set) var state: HandTrackerState = .none {
        didSet {
            handDataForCurrentPose = []

            if case .confirmedPose(let handPose) = state {
                pastPoses.append(handPose)
            }
        }
    }

    // MARK: - Models
    private let interactionManager: InteractionManager
    public let calibrationModel: HandPoseCalibrationModel = HandPoseCalibrationModel()

    // MARK: - Properties
    // Hand pose data.
    private var handDataForCurrentPose: [Hand] = []
    private var pastPoses: [HandPose] = []
    // Pinch data.
    private var pinchGroupTimer: Timer? = nil
    private var currentNumberOfPinches = 0
    private var pinchDurationTimer: Timer? = nil
    private var pinchDuration = 0

    // MARK: - Interactions
    /// Maps to all the index tip points for the current pose.
    private func getIndexLocations() -> [CGPoint] {
        handDataForCurrentPose.map {
            $0.tipLocation(finger: .index)
        }
    }

    /// Calculates the total delta of X and Y for the current pose.
    private func getXYDelta() -> (CGFloat, CGFloat, Int) {
        let indexLocations: [CGPoint] = getIndexLocations()

        // Calculate the differences in x and y coordinates.
        let xDifferences = zip(
            indexLocations, indexLocations.dropFirst()
        ).map { $1.x - $0.x }
        let yDifferences = zip(
            indexLocations, indexLocations.dropFirst()
        ).map { $1.y - $0.y }

        // Sum up the differences to assess overall movement.
        let totalXChange = xDifferences.reduce(0, +)
        let totalYChange = yDifferences.reduce(0, +)

        return (totalXChange, totalYChange, xDifferences.count)
    }

    /// Using X and Y delta changes from the point interaction, moves an on screen cursor.
    private func onPoint() {
        let indexLocations: [CGPoint] = getIndexLocations()
        guard let currentLocation = indexLocations.last,
            let previousLocation = indexLocations.dropLast().last
        else {
            return
        }

        // Find delta of x/y to move the cursor.
        // Calculate the differences in x and y coordinates.
        let xDifference = currentLocation.x - previousLocation.x
        let yDifference = currentLocation.y - previousLocation.y

        interactionManager.moveCursorOffset(
            by: .init(
                x: xDifference * UXDefaults.movementMultiplier.width,
                y: yDifference * UXDefaults.movementMultiplier.height
            )
        )
    }

    private func onPinch() {
        // If there is not already a timer tracking the pinch, add one.
        if pinchDurationTimer == nil {
            if let pinchGroupTimer = pinchGroupTimer, pinchGroupTimer.isValid {
                currentNumberOfPinches += 1
                pinchGroupTimer.invalidate()
            }

            pinchDuration = 0
            pinchDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                self.pinchDuration += 1
            }
        }
    }

    private func onNone() {
        // Clear the pinch timer.
        pinchDurationTimer?.invalidate()
        pinchDurationTimer = nil

        pinchGroupTimer = Timer.scheduledTimer(
            withTimeInterval: HandTrackerDefaults.MaximumPinchSeperationTime,
            repeats: false,
            block: { _ in
                self.checkForTap()
                self.pinchGroupTimer = nil
                self.currentNumberOfPinches = 0
            }
        )

        checkForTap()
    }

    @discardableResult
    private func checkForTap() -> Bool {
        // If the previous pose was a pinch, then detect if a "tap" was intended.
        func checkPinchType() {
            if pinchDuration >= HandTrackerDefaults.LongPinchDuration {
                interactionManager.onLongTap(duration: pinchDuration)
            } else {
                interactionManager.onTap(numberOfTaps: currentNumberOfPinches)
            }

            // Add another none pose so that the tap is not re-recoginized.
            pastPoses.append(.none)
        }

        let poses = pastPoses.dropLast()
        if case .pinch = poses.last {
            return true
            
            /*
            let numberOfPoses = poses.count

            // Need at least 3 poses in the history to detect intent [point, none, pinch] or possibly [point, pinch].
            // A tap can only come from a point and then pinch.
            if poses.count == 2,
                poses[(numberOfPoses - 2)...(numberOfPoses - 1)] == [.point, .pinch]
            {
                checkPinchType()
            } else if numberOfPoses >= 3,
                poses[(numberOfPoses - 3)...(numberOfPoses - 1)] == [.point, .none, .pinch]
                    || poses[(numberOfPoses - 2)...(numberOfPoses - 1)] == [.point, .pinch]
            {
                checkPinchType()
            } else {
                return false
            }
             */
        }

        return false
    }

    @discardableResult
    private func checkForScroll() -> Bool {
        let (totalXChange, totalYChange, numberOfPoints) = getXYDelta()
        let direction: Axis = totalYChange >= totalXChange ? .vertical : .horizontal
        let delta = direction == .vertical ? totalYChange : totalXChange

        guard numberOfPoints > 5, delta >= HandTrackerDefaults.MinimumScrollDelta else {
            return false
        }

        interactionManager.onScroll(
            direction: direction,
            distance: delta
        )

        return true
    }

    // MARK: - init
    init(interactionManager: InteractionManager) {
        self.interactionManager = interactionManager
    }
}

// MARK: - HandTrackerDelegate
extension HandTrackerModel: HandTrackerDelegate {
    func handDidChange(to value: Hand) {
        self.currentHand = value
        self.calibrationModel.receivedNewHand(data: value)
        self.handDataForCurrentPose.append(value)

        if case .confirmedPose(let handPose) = state {
            switch handPose {
            case .pinch:
                onPinch()
            case .point:
                onPoint()
            case .twoFinger:
                checkForScroll()
            case .none:
                onNone()
            }
        }
    }

    func handPoseDidChange(to value: HandPose) {
        guard calibrationModel.calibrationState == .Calibrated else {
            state = .none
            return
        }

        switch state {
        case .none:
            state = .possiblePose(handPose: value, amount: 1)
        case .possiblePose(let pose, let amount):
            if pose == value {
                let updatedAmount = amount + 1
                // If this pose has been seen more than the required ConfirmationAmount, we can confirm it as active.
                // Or just track that we have seen it again.
                if updatedAmount >= HandTrackerDefaults.ConfirmationAmount {
                    state = .confirmedPose(handPose: value)
                } else {
                    state = .possiblePose(handPose: value, amount: updatedAmount)
                }
            } else {
                state = .possiblePose(handPose: value, amount: 1)
            }
        case .confirmedPose(let pose):
            if pose != value {
                state = .possiblePose(handPose: value, amount: 1)
            }
        }
    }

    func handPoseConfidenceChanged(
        thumb: VNConfidence,
        index: VNConfidence,
        middle: VNConfidence,
        ring: VNConfidence,
        litte: VNConfidence
    ) {
        let highQuality: VNConfidence = 0.5
        let lowQuality: VNConfidence = UXDefaults.minimumCaptureQuality

        if thumb > highQuality,
            index > highQuality,
            middle > highQuality,
            ring > highQuality,
            litte > highQuality
        {
            quality = .Detected
        } else if thumb > lowQuality,
            index > lowQuality,
            middle > lowQuality,
            ring > lowQuality,
            litte > lowQuality
        {
            quality = .DetectedLowQuality
        } else {
            quality = .NotDetected
            state = .none
        }
    }
}
