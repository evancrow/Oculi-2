//
//  HandTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Combine
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
    static let DragThreshold: Double = 50
}

class HandTrackerModel: ObservableObject {
    // MARK: - Published
    @Published public private(set) var quality: VisionQualityState = .NotDetected
    @Published public private(set) var currentHand: Hand?
    @Published public private(set) var state: HandTrackerState = .none {
        didSet {
            handDataForCurrentPose = []
        }
    }

    // MARK: - Models
    private let interactionManager: InteractionManager
    public let calibrationModel: HandPoseCalibrationModel
    private var calibrationStateListener: AnyCancellable?

    // MARK: - Properties
    // Hand pose data.
    private var handDataForCurrentPose: [Hand] = []
    private var pastHands: [Hand] = []
    // Pinch data.
    private var pinching = false {
        didSet {
            interactionManager.switchToDragging = pinching
        }
    }
    // Grouped pinches.
    private var pinchGroupTimer: Timer? = nil
    private var currentNumberOfPinches = 0
    // Long pinches.
    private var pinchDurationTimer: Timer? = nil
    private var pinchDuration = 0

    /// Used to reset all data points.
    /// Useful for when recalibrating or detection stopped.
    func resetAll() {
        currentHand = nil
        handDataForCurrentPose = []
        pastHands = []

        pinching = false
        pinchGroupTimer = nil
        currentNumberOfPinches = 0

        pinchDurationTimer = nil
        pinchDuration = 0
    }

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

    private func onPinch() {
        guard !pinching else {
            return
        }

        // Set pinching to true so duplicate notifications are not sent.
        pinching = true

        // Start a timer to count how long the pinch is held.
        pinchDuration = 0
        pinchDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.pinchDuration += 1
        }

        currentNumberOfPinches += 1
        pinchGroupTimer?.invalidate()
    }

    private func pinchingStopped() {
        guard pinching else {
            return
        }

        print("PINCHING STOPPED")
        pinching = false

        pinchDurationTimer?.invalidate()
        pinchGroupTimer = Timer.scheduledTimer(
            withTimeInterval: HandTrackerDefaults.MaximumPinchSeperationTime,
            repeats: false,
            block: { [self] _ in
                if pinchDuration >= HandTrackerDefaults.LongPinchDuration {
                    interactionManager.onLongTap(
                        duration: pinchDuration
                    )
                } else {
                    interactionManager.onTap(
                        numberOfTaps: currentNumberOfPinches
                    )
                }

                // Reset the long pinch timer.
                pinchDuration = 0
                pinchDurationTimer = nil

                // Reset the group of pinches.
                currentNumberOfPinches = 0
                pinchGroupTimer = nil
            }
        )
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
        self.calibrationModel = HandPoseCalibrationModel()
        self.calibrationStateListener = self.calibrationModel.$calibrationState.sink { state in
            if state == .NotCalibrated || state == .NotCalibrated {
                self.resetAll()
            }
        }
    }
}

// MARK: - HandTrackerDelegate
extension HandTrackerModel: HandTrackerDelegate {
    func handDidChange(to value: Hand) {
        self.calibrationModel.receivedNewHand(data: value)

        guard calibrationModel.calibrationState == .Calibrated else {
            return
        }

        self.currentHand = value
        self.pastHands.append(value)
        self.handDataForCurrentPose.append(value)

        switch state {
        case .confirmedPose(let handPose):
            switch handPose {
            case .pinch:
                onPinch()
            default:
                pinchingStopped()
            }
        default:
            pinchingStopped()
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
        let highQuality: VNConfidence = UXDefaults.highCaptureQuality
        let lowQuality: VNConfidence = UXDefaults.minimumCaptureQuality

        if thumb > highQuality,
            index > highQuality,
            middle > lowQuality
        {
            quality = .Detected
        } else if thumb > lowQuality,
            index > lowQuality,
            middle > lowQuality,
            ring > lowQuality
        {
            quality = .DetectedLowQuality
        } else {
            quality = .NotDetected
            state = .none
            // resetAll()
        }
    }
}
