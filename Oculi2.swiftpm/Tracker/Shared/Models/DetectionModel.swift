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
                
                let detectCaptureQualityRequest = VNDetectFaceCaptureQualityRequest {
                    [weak self] request, error in
                    self?.detectedFaceQualityRequest(request, error, delegate)
                }
                detectCaptureQualityRequest.revision = VNDetectFaceCaptureQualityRequestRevision2

                detectionRequests.append(
                    contentsOf: [
                        detectFaceRectanglesRequest,
                        detectCaptureQualityRequest,
                    ]
                )
            case .Hands(let delegate):
                let detectHandPoseRequest = VNDetectHumanHandPoseRequest {
                    [weak self] request, error in
                    self?.detectedHandPose(request, error, delegate)
                }
                detectHandPoseRequest.maximumHandCount = 1
                detectHandPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1

                detectionRequests.append(detectHandPoseRequest)
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
        func onFail(location: String) {
            DispatchQueue.main.async {
                delegate.handPoseDidChange(
                    to: .none
                )
                delegate.handPoseConfidenceChanged(
                    thumb: .nan,
                    index: .nan,
                    middle: .nan,
                    ring: .nan,
                    litte: .nan
                )

                print("[Error] detectedHandPose failed at: \(location)")
            }
        }

        guard let results = request.results as? [VNHumanHandPoseObservation],
            let result = results.first
        else {
            // onFail(location: "Request Results")
            return
        }

        // Get the points for each finger.
        guard let thumbPoints = try? result.recognizedPoints(.thumb),
            let indexFingerPoints = try? result.recognizedPoints(.indexFinger),
            let middleFingerPoints = try? result.recognizedPoints(.middleFinger),
            let ringFingerPoints = try? result.recognizedPoints(.ringFinger),
            let littleFingerPoints = try? result.recognizedPoints(.littleFinger)
        else {
            onFail(location: "Find Points")
            return
        }

        // Look for tip points.
        guard let thumbTipPoint = thumbPoints[.thumbTip],
            let indexTipPoint = indexFingerPoints[.indexTip],
            let middleTipPoint = middleFingerPoints[.middleTip],
            let ringTipPoint = ringFingerPoints[.ringTip],
            let littleTipPoint = littleFingerPoints[.littleTip]
        else {
            onFail(location: "Tip Points")
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
