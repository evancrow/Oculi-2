//
//  FaceTrackerDelegate.swift
//  EyeTracker
//
//  Created by Evan Crow on 3/1/22.
//

import Foundation
import SwiftUI
import Vision

protocol FaceTrackerDelegate {
    func faceGeometryDidChange(_ geometry: FaceGeometry)
    func faceCaptureQualityDidChange(_ quality: VisionQualityState)
}
