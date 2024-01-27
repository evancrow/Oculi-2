//
//  DetectionModel.swift
//
//
//  Created by Evan Crow on 1/11/24.
//

import SwiftUI
import Vision

enum DetectionTypes {
    case Face(delegate: FaceTrackerDelegate)
    case Hands(delegate: HandTrackerDelegate)
}

class DetectionModel {
    // MARK: - Properties
    let detectionTypes: [DetectionTypes]

    // MARK: - Detection Request
    public func createDetectionRequests(
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        requestHandlerOptions: [VNImageOption: AnyObject]
    ) {
        var detectionRequests: [VNImageBasedRequest] = []

        for type in detectionTypes {
            switch type {
            case .Face(let delegate):
                let detectFaceRectanglesRequest = VNDetectFaceRectanglesRequest {
                    [weak self] request, error in
                    self?.detectedFaceRectangles(request, error, delegate)
                }
                detectFaceRectanglesRequest.revision = VNDetectFaceRectanglesRequestRevision3

                let detectFaceLandmarksRequest = VNDetectFaceLandmarksRequest {
                    [weak self] request, error in
                    self?.detectedFaceLandmarksRequest(request, error, delegate)
                }
                detectFaceLandmarksRequest.revision = VNDetectFaceRectanglesRequestRevision3

                let detectCaptureQualityRequest = VNDetectFaceCaptureQualityRequest {
                    [weak self] request, error in
                    self?.detectedFaceQualityRequest(request, error, delegate)
                }
                detectCaptureQualityRequest.revision = VNDetectFaceCaptureQualityRequestRevision2

                detectionRequests.append(
                    contentsOf: [
                        detectFaceRectanglesRequest,
                        detectFaceLandmarksRequest,
                        detectCaptureQualityRequest,
                    ]
                )
            case .Hands(let delegate):
                let detectFaceRectanglesRequest = VNDetectHumanHandPoseRequest {
                    [weak self] request, error in
                    self?.detectedHandPose(request, error, delegate)
                }

                detectionRequests.append(detectFaceRectanglesRequest)
            }
        }

        performDetectRequests(
            requests: detectionRequests,
            pixelBuffer: pixelBuffer,
            orientation: orientation,
            requestHandlerOptions: requestHandlerOptions
        )
    }

    private func performDetectRequests(
        requests: [VNRequest]?,
        pixelBuffer: CVPixelBuffer,
        orientation: CGImagePropertyOrientation,
        requestHandlerOptions: [VNImageOption: AnyObject]
    ) {
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: orientation,
            options: requestHandlerOptions
        )

        do {
            guard let requests = requests else {
                return
            }

            try imageRequestHandler.perform(requests)
        } catch let error as NSError {
            NSLog("Failed to perform request: %@", error)
        }
    }

    // MARK: - Face Handlers
    private func detectedFaceRectangles(
        _ request: VNRequest,
        _ error: Error?,
        _ delegate: FaceTrackerDelegate
    ) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first
        else {
            return
        }

        let faceGeometry = FaceGeometry(
            boundingBox: result.boundingBox,
            roll: Double(truncating: result.roll ?? 0),
            pitch: Double(truncating: result.pitch ?? 0),
            yaw: Double(truncating: result.yaw ?? 0)
        )

        DispatchQueue.main.async {
            delegate.faceGeometryDidChange(faceGeometry)
        }
    }

    private func detectedFaceLandmarksRequest(
        _ request: VNRequest,
        _ error: Error?,
        _ delegate: FaceTrackerDelegate
    ) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first,
            let landmarks = result.landmarks
        else {

            return
        }

        DispatchQueue.main.async {
            delegate.landmarksDidChange(landmarks)
        }
    }

    private func detectedFaceQualityRequest(
        _ request: VNRequest,
        _ error: Error?,
        _ delegate: FaceTrackerDelegate
    ) {
        guard let results = request.results as? [VNFaceObservation],
            let result = results.first,
            let captureQuality = result.faceCaptureQuality
        else {

            delegate.faceCaptureQualityDidChange(.NotDetected)
            return
        }

        delegate.faceCaptureQualityDidChange(
            captureQuality > UXDefaults.minimumCaptureQuality ? .Detected : .DetectedLowQuality
        )
    }

    // MARK: - Hand Handlers
    private func detectedHandPose(
        _ request: VNRequest,
        _ error: Error?,
        _ delegate: HandTrackerDelegate
    ) {
        guard let results = request.results as? [VNHumanHandPoseObservation],
            let result = results.first
        else {

            return
        }

        // Get the points for each finger.
        guard let thumbPoints = try? result.recognizedPoints(.thumb),
            let indexFingerPoints = try? result.recognizedPoints(.indexFinger),
            let middleFingerPoints = try? result.recognizedPoints(.middleFinger),
            let ringFingerPoints = try? result.recognizedPoints(.ringFinger),
            let littleFingerPoints = try? result.recognizedPoints(.littleFinger)
        else {
            return
        }

        // Look for tip points.
        guard let thumbTipPoint = thumbPoints[.thumbTip],
            let indexTipPoint = indexFingerPoints[.indexTip],
            let middleTipPoint = middleFingerPoints[.middleTip],
            let ringTipPoint = ringFingerPoints[.ringTip],
            let littleTipPoint = littleFingerPoints[.littleTip]
        else {
            return
        }

        // Look for knuckle points.
        guard let thumbKnucklePoint = thumbPoints[.thumbIP],
            let indexKnucklePoint = indexFingerPoints[.indexMCP],
            let middleKnucklePoint = middleFingerPoints[.middleMCP],
            let ringKnucklePoint = ringFingerPoints[.ringMCP],
            let littleKnucklePoint = littleFingerPoints[.littleMCP]
        else {
            return
        }

        DispatchQueue.main.async {
            let hand = Hand(
                tips: [
                    .thumb: thumbTipPoint.location,
                    .index: indexTipPoint.location,
                    .middle: middleTipPoint.location,
                    .ring: ringTipPoint.location,
                    .little: littleTipPoint.location,
                ],
                knuckles: [
                    .thumb: thumbKnucklePoint.location,
                    .index: indexKnucklePoint.location,
                    .middle: middleKnucklePoint.location,
                    .ring: ringKnucklePoint.location,
                    .little: littleKnucklePoint.location,
                ]
            )

            // Convert points from Vision coordinates to AVFoundation coordinates.
            delegate.handPoseDidChange(
                to: HandPoseModel.predictHandPose(from: hand)
            )
            delegate.handDidChange(to: hand)
            delegate.handPoseConfidenceChanged(
                thumb: thumbTipPoint.confidence,
                index: indexTipPoint.confidence,
                middle: middleTipPoint.confidence,
                ring: ringTipPoint.confidence,
                litte: littleTipPoint.confidence
            )
        }
    }

    // MARK: - init
    init(detectionTypes: [DetectionTypes]) {
        self.detectionTypes = detectionTypes
    }
}
