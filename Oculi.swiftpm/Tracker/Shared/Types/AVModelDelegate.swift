//
//  AVModelDelegate.swift
//
//
//  Created by Evan Crow on 1/15/24.
//

import AVKit
import Vision

protocol AVModelDelegate {
    func onCaptureOutput(
        pixelBuffer: CVImageBuffer,
        orientation: CGImagePropertyOrientation,
        requestHandlerOptions: [VNImageOption: AnyObject]
    )
}
