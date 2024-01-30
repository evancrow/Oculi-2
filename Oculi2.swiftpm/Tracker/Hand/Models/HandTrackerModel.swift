//
//  HandTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Foundation
import SwiftUI
import Vision

class HandTrackerModel: ObservableObject {
    // MARK: - Published
    @Published public private(set) var quality: VisionQualityState = .NotDetected
    @Published public private(set) var currentHand: Hand?
    @Published public private(set) var currentHandPose: HandPose = .none {
        didSet {
            handDataForCurrentPose = []
            pastPoses.append(currentHandPose)
        }
    }

    // MARK: - Models
    private let interactionManager: InteractionManager
    public let calibrationModel: HandPoseCalibrationModel = HandPoseCalibrationModel()

    // MARK: - Data
    private var handDataForCurrentPose: [Hand] = []
    private var pastPoses: [HandPose] = []

    // MARK: - Interactions
    private func getIndexLocations() -> [CGPoint] {
        handDataForCurrentPose.map {
            $0.tipLocation(finger: .index)
        }
    }

    // Calculates the total X/Y delta for the current pose.
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

    private func checkForPan() {
        let (totalXChange, totalYChange, numberOfPoints) = getXYDelta()
        // Determine if the changes are significant.
        let xPanThreshold: CGFloat = 10  // Set a threshold for significant change in x.
        let yPanThreshold: CGFloat = 10  // Set a threshold for significant change in y.

        guard numberOfPoints > 5 else {
            return
        }

        print("TOTALX CHANGE: ", totalXChange)
        print("TOTALY CHANGE: ", totalYChange)

        // Check for horizontal pan.
        if abs(totalXChange) > CGFloat(numberOfPoints) * xPanThreshold {
            if totalXChange > 0 {
                print("Horizontal pan to the right detected")
            } else {
                print("Horizontal pan to the left detected")
            }
        }

        // Check for vertical pan.
        if abs(totalYChange) > CGFloat(numberOfPoints) * yPanThreshold {
            if totalYChange > 0 {
                print("Vertical pan downwards detected")
            } else {
                print("Vertical pan upwards detected")
            }
        }
    }

    private func moveCursor() {
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
    }

    private func checkForTap() {
        guard currentHandPose == .pinch else {
            return
        }
        
        if pastPoses.last == .point {
            print("Tap")
            // return true
        } else if pastPoses.count >= 3, pastPoses[pastPoses.count - 2...pastPoses.count - 1] == [.pinch, .none] {
            print("Tap 2")
            // return true
        }
    }

    private func checkForZoom() {
        // Idk what to do here right now.
    }

    private func checkForScroll() {
        let (totalXChange, totalYChange, numberOfPoints) = getXYDelta()

        guard numberOfPoints > 5 else {
            return
        }

        // Find the x/y delta.
        // Which ever is more significant is the direction of scroll.
        if totalYChange >= totalXChange {
            print("YScroll:", totalYChange)
        } else {
            print("XScroll:", totalYChange)
        }
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

        switch currentHandPose {
        case .flat:
            checkForPan()
        case .pinch:
            checkForTap()
        case .point:
            moveCursor()
        case .twoFinger:
            checkForScroll()
        case .none:
            return
        }
    }

    func handPoseDidChange(to value: HandPose) {
        if calibrationModel.calibrationState == .Calibrated
            && quality != .NotDetected
            && currentHandPose != value
        {
            self.currentHandPose = value
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
        let lowQuality: VNConfidence = 0.3

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
            currentHandPose = .none
        }
    }
}
