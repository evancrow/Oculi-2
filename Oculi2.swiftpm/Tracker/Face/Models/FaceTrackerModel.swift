//
//  FaceTrackerModel.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import Foundation
import SwiftUI
import Vision

public class FaceTrackerModel: ObservableObject {
    private var interactionManager: InteractionManager!

    @Published public private(set) var quality: VisionQualityState = .NotDetected
    @Published public private(set) var isTracking = false
    var keyboardVisible = false

    public var paused: Bool {
        quality != .Detected || isBlinking || keyboardVisible
    }

    // Blinking states
    @Published public private(set) var isBlinking: Bool = false {
        didSet {
            if oldValue != isBlinking {
                blinkStateChanged()
            }
        }
    }

    // Calibration
    @Published public private(set) var showBlinkingCalibrationView = false
    @Published public private(set) var blinkingHasBeenCalibrated = false
    @Published public private(set) var isCalibratingEyes = false

    // Current blink info.
    private var currentBlinkDuration = 0
    private var currentNumberOfBlinks = 0

    // Blink timers
    private var blinkGroupTimer: Timer? = nil
    private var blinkDurationTimer: Timer? = nil

    /// Geometry from when tracking first began, used as a baseline.
    private var originGeometry: FaceGeometry? = nil

    private var leftEyePoints = [CGPoint]()
    private var rightEyePoints = [CGPoint]()

    // MARK: - Public Functions
    public func toggleTrackingState() {
        if isTracking {
            endTracking()
        } else {
            startTracking()
        }
    }

    public func resetOffset() {
        originGeometry = nil
        interactionManager.resetCursorOffset()
    }

    public func startTracking() {
        if !blinkingHasBeenCalibrated {
            withAnimation {
                showBlinkingCalibrationView = true
            }
        } else {
            resetOffset()
            isTracking = true
        }

        // UIApplication.shared.isIdleTimerDisabled = true
    }

    public func endTracking() {
        isTracking = false
        interactionManager.resetCursorOffset()

        // UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - Blinking
    private func getEyeHeight(points: [CGPoint], useAbs: Bool = false) -> CGFloat {
        guard quality == .Detected, points.count == 6 else {
            return -1
        }

        // Point layout (eye):
        // /-2-3-\
        // 1  •  4
        // \-6-5-/

        let p2 = points[1]
        let p3 = points[2]
        let p5 = points[4]
        let p6 = points[5]

        let leftHeight = useAbs ? abs(p2.y - p6.y) : (p2.y - p6.y)
        let rightHeight = useAbs ? abs(p3.y - p5.y) : (p3.y - p5.y)

        // return the average of the two
        return (leftHeight + rightHeight) / 2
    }

    private func checkIfEyeIsBlinking(points: [CGPoint]) -> Bool {
        let eyeHeight = getEyeHeight(points: points, useAbs: true)
        let threshold = LegacyUXDefaults.isBlinkingMargin

        guard eyeHeight > 0 else {
            return false
        }

        return eyeHeight < threshold
    }

    private func blinkStateChanged() {
        if isBlinking {
            SoundEffectHelper.shared.playAudio(for: .onBlink)

            // User blinked again very quickly,
            // should count this as another blink in the group.
            if let blinkGroupTimer = blinkGroupTimer, blinkGroupTimer.isValid {
                currentNumberOfBlinks += 1
                blinkGroupTimer.invalidate()
            }

            blinkDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                SoundEffectHelper.shared.playAudio(for: .onBlink)
                self.currentBlinkDuration += 1
            }
        } else {
            longBlinkEnded()

            blinkDurationTimer?.invalidate()
            currentBlinkDuration = 0

            // User did not blink again in a close proximity to the last one.
            // Reset the group timer.
            blinkGroupTimer = Timer.scheduledTimer(
                withTimeInterval: LegacyUXDefaults.maximumBlinkSeperationTime,
                repeats: false,
                block: { _ in
                    self.blinksEnded()
                    self.blinkGroupTimer = nil
                    self.currentNumberOfBlinks = 0
                }
            )
        }
    }

    private func longBlinkEnded() {
        let seconds = currentBlinkDuration + 1

        if seconds == LegacyUXDefaults.toggleTrackingBlinkDuration {
            // Disable for now, as it could be confusing to the user.
            // toggleTrackingState()
        }

        interactionManager.onLongBlink(duration: seconds)
    }

    // Called when the user stops blinking
    private func blinksEnded() {
        let numberOfBlinks = currentNumberOfBlinks + 1
        // interactionManager.onBlink(onBlink: (numberOfBlinks, getCursorBoundingBox()), isTracking: isTracking)
    }

    // Calibration
    public func startBlinkingCalibration() {
        // How many measurements to take
        let count = 20

        isCalibratingEyes = true

        // Add a small delay to make sure the user closes their eyes
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            var eyeHeights = [(CGFloat, CGFloat)]()

            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
                eyeHeights.append(
                    (getEyeHeight(points: leftEyePoints), getEyeHeight(points: rightEyePoints)))

                if eyeHeights.count == count {
                    timer.invalidate()

                    // Get average of each height
                    let leftHeights = eyeHeights.map { $0.0 }
                    let leftAverage = leftHeights.reduce(0, +) / CGFloat(count)

                    let rightHeights = eyeHeights.map { $0.1 }
                    let rightAverage = rightHeights.reduce(0, +) / CGFloat(count)

                    let bothEyeAverage = ((leftAverage + rightAverage) / 2)

                    LegacyUXDefaults.isBlinkingMargin = bothEyeAverage + (bothEyeAverage * 0.2)

                    blinkingHasBeenCalibrated = true
                    isCalibratingEyes = false

                    SoundEffectHelper.shared.playAudio(for: .onComplete)
                }
            }
        }
    }

    public func displayBlinkingCalibrationViewIfNeeded() {
        guard !blinkingHasBeenCalibrated else {
            return
        }

        showBlinkingCalibrationView = true
    }

    public func hideBlinkingCalibrationViewIfCompleted() {
        guard blinkingHasBeenCalibrated else {
            return
        }

        showBlinkingCalibrationView = false
    }

    public func resetBlinkingCalibration() {
        blinkingHasBeenCalibrated = false
        showBlinkingCalibrationView = true
    }

    // MARK: - Head Movement
    private func updateOffset(with geometry: FaceGeometry) {
        guard let originGeometry = originGeometry else {
            originGeometry = geometry
            return
        }

        let yaw = geometry.yaw
        let originYaw = originGeometry.yaw
        let xOffset: CGFloat = {
            if yaw > originYaw {
                return yaw - originYaw
            } else {
                return -(originYaw - yaw)
            }
        }()

        let pitch = geometry.pitch
        let originPitch = originGeometry.pitch
        let yOffset: CGFloat = {
            if pitch > originPitch {
                return pitch - originPitch
            } else {
                return -(originPitch - pitch)
            }
        }()

        let newXOffset = (xOffset * UXDefaults.movementMultiplier.width)
        let newYOffset = (yOffset * UXDefaults.movementMultiplier.height)

        interactionManager.moveCursorOffset(by: CGPoint(x: newXOffset, y: newYOffset))
    }

    init(interactionManager: InteractionManager) {
        self.interactionManager = interactionManager
    }
}

// MARK: - FaceTrackerDelegate
extension FaceTrackerModel: FaceTrackerDelegate {
    func landmarksDidChange(_ landmarks: VNFaceLandmarks2D) {
        if let leftEyePoints = landmarks.leftEye?.normalizedPoints,
            let rightEyePoints = landmarks.rightEye?.normalizedPoints
        {

            self.leftEyePoints = leftEyePoints
            self.rightEyePoints = rightEyePoints

            let leftEyeBlinking = checkIfEyeIsBlinking(points: leftEyePoints)
            let rightEyeBlinking = checkIfEyeIsBlinking(points: rightEyePoints)
            let blinking = leftEyeBlinking && rightEyeBlinking

            // Don't update state if it's not necessary.
            if blinking != isBlinking && blinkingHasBeenCalibrated {
                isBlinking = leftEyeBlinking && rightEyeBlinking
            }
        }
    }

    func faceGeometryDidChange(_ geometry: FaceGeometry) {
        guard isTracking, !paused else {
            return
        }

        updateOffset(with: geometry)
    }

    func faceCaptureQualityDidChange(_ quality: VisionQualityState) {
        DispatchQueue.main.async { [self] in
            self.quality = quality

            if self.quality != .Detected {
                isBlinking = false
            }
        }
    }
}
