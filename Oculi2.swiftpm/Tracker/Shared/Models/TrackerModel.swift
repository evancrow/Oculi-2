//
//  TrackerModel.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import Foundation
import SwiftUI
import Vision

public class TrackerModel: ObservableObject {
    // MARK: - Combine Properties
    @ObservedObject var avModel: AVModel
    @ObservedObject var faceTrackerModel: FaceTrackerModel
    @ObservedObject var handTrackerModel: HandTrackerModel

    // MARK: - Properties
    let detectionModel: DetectionModel
    let interactionManager = InteractionManager()

    // MARK: - Methods
    /// Should be called if camera permission state changes
    public func resetAVModel() {
        self.avModel.config()
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
                .Hands(delegate: handTrackerModel)
            ]
        )

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
