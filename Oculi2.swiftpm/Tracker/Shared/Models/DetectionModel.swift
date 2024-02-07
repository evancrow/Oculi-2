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
    let handDataBuffer = Buffer<Hand>(size: HandTrackerDefaults.HandDataAverage)

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
                    to: Finger.allCases.reduce(into: [:]) { result, finger in
                        result[finger] = .nan
                    }
                )

                // print("[Error] detectedHandPose failed at: \(location)")
            }
        }

        guard let results = request.results as? [VNHumanHandPoseObservation],
            let result = results.first
        else {
            onFail(location: "Request Results")
            return
        }

        // Look for tip points.
        guard let thumbTipPoint = try? result.recognizedPoint(.thumbTip),
            let indexTipPoint = try? result.recognizedPoint(.indexTip),
            let middleTipPoint = try? result.recognizedPoint(.middleTip),
            let ringTipPoint = try? result.recognizedPoint(.ringTip),
            let littleTipPoint = try? result.recognizedPoint(.littleTip)
        else {
            onFail(location: "Tip Points")
            return
        }

        handDataBuffer.enqueue(
            value: Hand(
                tips: [
                    .thumb: thumbTipPoint.location,
                    .index: indexTipPoint.location,
                    .middle: middleTipPoint.location,
                    .ring: ringTipPoint.location,
                    .little: littleTipPoint.location,
                ],
                confidence: [
                    .thumb: thumbTipPoint.confidence,
                    .index: indexTipPoint.confidence,
                    .middle: middleTipPoint.confidence,
                    .ring: ringTipPoint.confidence,
                    .little: littleTipPoint.confidence,
                ]
            )
        )

        let allHands = self.handDataBuffer.getAllValues()

        // Average the data for the last few hands to reduce variation in the data.
        var averageTipData: [Finger: CGPoint] = [:]
        var averageConfidenceData: [Finger: VNConfidence] = [:]
        for finger in Finger.allCases {
            for hand in allHands {
                averageTipData[finger, default: CGPoint()].add(
                    point: hand.tipLocation(finger: finger)
                )
                averageConfidenceData[finger, default: 0] += hand.confidence[finger, default: 0]
            }
        }
        let averageHand = Hand(
            tips: averageTipData.mapValues { $0.apply { $0 / CGFloat(allHands.count) } },
            confidence: averageConfidenceData.mapValues { $0 / Float(allHands.count) }
        )

        DispatchQueue.main.async {
            delegate.handPoseDidChange(to: HandPoseModel.predictHandPose(from: averageHand))
            delegate.handDidChange(to: averageHand)
            delegate.handPoseConfidenceChanged(to: averageHand.confidence)
        }
    }

    // MARK: - init
    init(detectionTypes: [DetectionTypes]) {
        self.detectionTypes = detectionTypes
    }
}
