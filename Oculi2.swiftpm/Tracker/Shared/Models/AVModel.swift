//
//  AVModel.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/1/22.
//

import AVKit
import Combine
import Vision

class AVModel: NSObject, ObservableObject {
    @Published private(set) var failedToConfigure = false
    var delegate: AVModelDelegate!

    private var captureSession: AVCaptureSession?

    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoDataOutputQueue: DispatchQueue?

    private var captureDevice: AVCaptureDevice?
    private var captureDeviceResolution: CGSize = CGSize()

    // MARK: AVCapture Setup
    private func setupAVCaptureSession() {
        let captureSession = AVCaptureSession()

        if PermissionModel.shared.getPermissionState(permission: .camera) == .authorized {
            do {
                let inputDevice = try self.configureFrontCamera(for: captureSession)
                self.configureVideoDataOutput(
                    for: inputDevice.device,
                    resolution: inputDevice.resolution,
                    captureSession: captureSession
                )
                self.captureSession = captureSession

                captureSession.startRunning()

                return
            } catch {
                print("Error setting up AVCapture session: ", error.localizedDescription)
                failedToConfigure = true
            }

            self.teardownAVCapture()
        }
    }

    private func highestResolution420Format(for device: AVCaptureDevice) -> (
        format: AVCaptureDevice.Format, resolution: CGSize
    )? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)

        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format

            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription)
                == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(
                    deviceFormatDescription)
                if (highestResolutionFormat == nil)
                    || (candidateDimensions.width > highestResolutionDimensions.width)
                {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }

        if highestResolutionFormat != nil {
            let resolution = CGSize(
                width: CGFloat(highestResolutionDimensions.width),
                height: CGFloat(highestResolutionDimensions.height)
            )
            return (highestResolutionFormat!, resolution)
        }

        return nil
    }

    private func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (
        device: AVCaptureDevice, resolution: CGSize
    ) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInLiDARDepthCamera, .builtInWideAngleCamera], mediaType: .video,
            position: .front
        )

        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }

                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format

                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                    } else if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                    }

                    device.unlockForConfiguration()

                    return (device, highestResolution.resolution)
                }
            }
        }

        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }

    private func configureVideoDataOutput(
        for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession
    ) {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.evan.oculi")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }

        videoDataOutput.connection(with: .video)?.isEnabled = true

        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }

        self.captureDevice = inputDevice
        self.captureDeviceResolution = resolution

        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
    }

    // Removes infrastructure for AVCapture as part of cleanup.
    private func teardownAVCapture() {
        self.captureSession?.stopRunning()
        self.captureSession = nil

        self.videoDataOutput = nil
        self.videoDataOutputQueue = nil
    }

    // MARK: Helper Methods for Handling Device Orientation & EXIF
    private func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }

    // MARK: Orientation
    private func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation)
        -> CGImagePropertyOrientation
    {
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
        case .landscapeLeft:
            return .downMirrored
        case .landscapeRight:
            return .upMirrored
        default:
            return .leftMirrored
        }
    }

    private func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }

    // MARK: - init
    public override init() {
        super.init()
        self.config()
    }

    public func config() {
        self.setupAVCaptureSession()
    }
}

extension AVModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    // Handle delegate method callback on receiving a sample buffer.
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]

        let cameraIntrinsicData = CMGetAttachment(
            sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix,
            attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }

        delegate.onCaptureOutput(
            pixelBuffer: pixelBuffer,
            orientation: exifOrientationForCurrentDeviceOrientation(),
            requestHandlerOptions: requestHandlerOptions
        )
    }
}
