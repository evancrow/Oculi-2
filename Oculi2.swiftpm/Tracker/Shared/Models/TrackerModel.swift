//
//  TrackerModel.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import Combine
import Foundation
import SwiftUI
import Vision

public class TrackerModel: ObservableObject {
    // MARK: - Combine Properties
    @ObservedObject var avModel: AVModel
    @ObservedObject var faceTrackerModel: FaceTrackerModel
    @ObservedObject var handTrackerModel: HandTrackerModel

    @Published private(set) var trackingEnabled = false {
        didSet {
            interactionManager.interactionEnabled = trackingEnabled
        }
    }
    @Published private(set) var quality: VisionQualityState = .NotDetected
    private var faceQualityListener: AnyCancellable?
    private var handQualityListener: AnyCancellable?

    @Published var calibrated: Bool = false
    private var handCalibrationListener: AnyCancellable?

    // MARK: - Properties
    let detectionModel: DetectionModel
    let interactionManager = InteractionManager()

    // MARK: - Methods
    /// Should be called if camera permission state changes
    public func resetAVModel() {
        self.avModel.config()
    }

    public func updateQuality() {
        self.quality = faceTrackerModel.quality
    }

    @discardableResult
    public func enableTracking() -> Bool {
        if faceTrackerModel.captureOriginGeometry() {
            trackingEnabled = true
        } else {
            trackingEnabled = false
        }

        return trackingEnabled
    }

    public func disableTracking() {
        trackingEnabled = false
    }

    // MARK: - init
    init(avModel: AVModel) {
        self.avModel = avModel

        let faceTrackerModel = FaceTrackerModel(interactionManager: interactionManager)
        self.faceTrackerModel = faceTrackerModel

        let handTrackerModel = HandTrackerModel(interactionManager: interactionManager)
        self.handTrackerModel = handTrackerModel

        self.detectionModel = DetectionModel(
            detectionTypes: [
                .Face(delegate: faceTrackerModel),
                .Hands(delegate: handTrackerModel),
            ]
        )

        faceQualityListener = self.faceTrackerModel.$quality.sink { value in
            self.updateQuality()
        }

        handQualityListener = self.handTrackerModel.$quality.sink { value in
            self.updateQuality()
        }

        handCalibrationListener = self.handTrackerModel.calibrationModel.$calibrationState.sink {
            value in
            self.calibrated = value == .Calibrated
        }

        // Add the delegate to AVModel.
        self.avModel.delegate = self
        self.avModel.config()
    }
}

// MARK: - AVModelDelegate
extension TrackerModel: AVModelDelegate {
    func onCaptureOutput(
        pixelBuffer: CVImageBuffer,
        orientation: CGImagePropertyOrientation,
        requestHandlerOptions: [VNImageOption: AnyObject]
    ) {
        detectionModel.createDetectionRequests(
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            requestHandlerOptions: requestHandlerOptions
        )
    }
}
